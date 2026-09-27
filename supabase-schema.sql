-- ============================================================================
-- Volt&Go — Schéma Supabase (PostgreSQL 15 + PostGIS)
-- À exécuter une fois dans Supabase > SQL Editor, sur un projet NEUF.
-- Couvre : profils, signalements géolocalisés, votes, modération, anti-spam,
-- établissements, favoris, historique opt-in, expiration automatique, temps réel.
-- Les fonctions RPC ci-dessous sont celles appelées par SupabaseDataProvider.
-- ============================================================================

create extension if not exists postgis;
create extension if not exists pg_cron;   -- Supabase : Database > Extensions > pg_cron

-- ---------------------------------------------------------------------------
-- Villes (architecture Strasbourg → Grand Est → France → Europe)
-- ---------------------------------------------------------------------------
create table if not exists public.cities (
  id          text primary key,                     -- 'strasbourg'
  name        text not null,
  country     text not null default 'FR',
  bbox        geometry(Polygon, 4326) not null,
  transit_url text,                                 -- ex. Strass&Go
  created_at  timestamptz not null default now()
);
insert into public.cities (id, name, bbox, transit_url)
values ('strasbourg', 'Strasbourg', ST_MakeEnvelope(7.62, 48.49, 7.87, 48.66, 4326), 'https://alphakorner.github.io/Strass-Go/')
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Profils (1-1 avec auth.users). Le mot de passe est géré et haché par Supabase Auth.
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  first_name   text not null check (char_length(first_name) between 1 and 40),
  role         text not null default 'user' check (role in ('user', 'moderator', 'admin')),
  vehicle      jsonb,                                 -- { type, model, nominalKm, realKm }
  preferences  jsonb not null default '{}'::jsonb,
  trust        numeric(3,2) not null default 0.50 check (trust between 0 and 1),
  banned_until timestamptz,
  created_at   timestamptz not null default now()
);

-- Création automatique du profil à l'inscription (prénom transmis dans user_metadata)
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, first_name)
  values (new.id, coalesce(nullif(left(trim(new.raw_user_meta_data->>'first_name'), 40), ''), 'Usager'));
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- Rôle courant (utilisé par les politiques RLS)
create or replace function public.current_role_name() returns text
language sql stable security definer set search_path = public as $$
  select coalesce((select role from public.profiles where id = auth.uid()), 'anon')
$$;

-- ---------------------------------------------------------------------------
-- Types de signalement et durée de vie (mêmes valeurs que Logic.REPORT_TYPES)
-- Aucun type « radar » : article R413-15 du Code de la route.
-- ---------------------------------------------------------------------------
create table if not exists public.report_types (
  id     text primary key,
  label  text not null,
  ttl    interval not null
);
insert into public.report_types (id, label, ttl) values
  ('travaux', 'Travaux', '72 hours'),
  ('route_bloquee', 'Route bloquée', '6 hours'),
  ('deviation', 'Déviation', '24 hours'),
  ('obstacle', 'Danger', '2 hours'),
  ('chaussee', 'Route dégradée', '168 hours'),
  ('piste_bloquee', 'Piste cyclable bloquée', '4 hours'),
  ('recharge_ko', 'Problème de recharge', '24 hours'),
  ('vigilance', 'Zone de vigilance', '24 hours'),
  ('controle', 'Présence des forces de l''ordre', '90 minutes'),
  -- v1.0 : catalogue façon GPS communautaire
  ('nid_de_poule', 'Nid-de-poule', '240 hours'),
  ('ralentissement', 'Ralentissement', '1 hour'),
  ('accident', 'Accident / incident', '2 hours'),
  ('ralentisseur', 'Ralentisseur', '720 hours'),
  ('route_interdite', 'Route interdite', '720 hours'),
  ('recharge_ok', 'Recharge disponible', '168 hours'),
  ('reparation', 'Réparation', '168 hours'),
  ('parking', 'Parking vélo / trottinette', '720 hours'),
  ('autre', 'Autre information', '3 hours')
on conflict (id) do update set label = excluded.label, ttl = excluded.ttl;

-- ---------------------------------------------------------------------------
-- Signalements
-- ---------------------------------------------------------------------------
create table if not exists public.reports (
  id          uuid primary key default gen_random_uuid(),
  city_id     text not null default 'strasbourg' references public.cities(id),
  type        text not null references public.report_types(id),
  geom        geography(Point, 4326) not null,
  comment     text check (comment is null or char_length(comment) <= 140),
  created_by  uuid references public.profiles(id) on delete set null,
  created_at  timestamptz not null default now(),
  expires_at  timestamptz not null,
  confirms    int not null default 0,
  denies      int not null default 0,
  flags       int not null default 0,
  status      text not null default 'active' check (status in ('active', 'confirmed', 'disputed', 'expired', 'review', 'removed')),
  removed_reason text
);
create index if not exists reports_geom_idx on public.reports using gist (geom);
create index if not exists reports_live_idx on public.reports (expires_at) where status in ('active', 'confirmed', 'disputed');

create table if not exists public.report_votes (
  report_id  uuid references public.reports(id) on delete cascade,
  user_id    uuid references public.profiles(id) on delete cascade,
  vote       text not null check (vote in ('still', 'gone')),
  created_at timestamptz not null default now(),
  primary key (report_id, user_id)
);
create table if not exists public.report_flags (
  report_id  uuid references public.reports(id) on delete cascade,
  user_id    uuid references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (report_id, user_id)
);
create table if not exists public.moderation_log (
  id         bigint generated always as identity primary key,
  report_id  uuid,
  actor      uuid,
  action     text not null,
  reason     text,
  created_at timestamptz not null default now()
);

-- Recalcul du statut (même règle que Logic.reportState)
create or replace function public.report_status(r public.reports) returns text
language sql stable as $$
  select case
    when r.status = 'removed' then 'removed'
    when r.flags >= 3 then 'review'
    when now() >= r.expires_at then 'expired'
    when r.denies >= 2 and r.denies >= r.confirms then 'disputed'
    when r.confirms >= 2 and r.confirms > r.denies then 'confirmed'
    else 'active' end
$$;

-- ---------------------------------------------------------------------------
-- RPC : lecture des signalements visibles dans une zone
-- ---------------------------------------------------------------------------
create or replace function public.reports_in_bbox(min_lng float8, min_lat float8, max_lng float8, max_lat float8)
returns table (id uuid, type text, lng float8, lat float8, comment text, created_by uuid, author_name text, author_trust numeric,
               created_at timestamptz, expires_at timestamptz, confirms int, denies int, flags int, status text)
language sql stable security definer set search_path = public as $$
  select r.id, r.type, ST_X(r.geom::geometry), ST_Y(r.geom::geometry), r.comment, r.created_by, p.first_name, p.trust,
         r.created_at, r.expires_at, r.confirms, r.denies, r.flags, public.report_status(r)
  from public.reports r left join public.profiles p on p.id = r.created_by
  where r.geom && ST_MakeEnvelope(min_lng, min_lat, max_lng, max_lat, 4326)::geography
    and public.report_status(r) in ('active', 'confirmed', 'disputed')
    -- v0.3 : masquage préfectoral des contrôles (L130-11) : un contrôle dans une zone d'ordre actif n'est pas rediffusé
    and not (r.type = 'controle' and exists (
      select 1 from public.blackouts b where now() between b.starts_at and b.ends_at
        and ST_DWithin(r.geom, b.geom, b.radius_m)))
  order by r.created_at desc
  limit 500
$$;

-- ---------------------------------------------------------------------------
-- RPC : création avec anti-spam (45 s entre deux, 8 par heure) et fusion des doublons (50 m)
-- ---------------------------------------------------------------------------
create or replace function public.create_report(p_type text, p_lng float8, p_lat float8, p_comment text default null)
returns json language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid();
  pt geography := ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography;
  last_at timestamptz; n_hour int; dup uuid; new_id uuid; v_ttl interval; prof public.profiles;
begin
  if uid is null then raise exception 'Connexion requise' using errcode = '28000'; end if;
  select * into prof from public.profiles where id = uid;
  if prof.banned_until is not null and prof.banned_until > now() then raise exception 'Compte suspendu' using errcode = 'P0001'; end if;
  if not exists (select 1 from public.cities where ST_Covers(bbox::geography, pt)) then raise exception 'Zone non couverte' using errcode = 'P0001'; end if;
  select rt.ttl into v_ttl from public.report_types rt where rt.id = p_type;
  if v_ttl is null then raise exception 'Type inconnu' using errcode = '22023'; end if;

  select max(created_at), count(*) filter (where created_at > now() - interval '1 hour')
    into last_at, n_hour from public.reports where created_by = uid and created_at > now() - interval '1 hour';
  if last_at is not null and last_at > now() - interval '45 seconds' then raise exception 'Patientez avant un nouveau signalement' using errcode = 'P0001'; end if;
  if n_hour >= 8 then raise exception 'Limite horaire atteinte' using errcode = 'P0001'; end if;

  select r.id into dup from public.reports r
   where r.type = p_type and public.report_status(r) in ('active', 'confirmed', 'disputed') and ST_DWithin(r.geom, pt, 50)
   order by ST_Distance(r.geom, pt) limit 1;
  if dup is not null then
    perform public.vote_report(dup, 'still');
    return json_build_object('id', dup, 'merged', true);
  end if;

  insert into public.reports (type, geom, comment, created_by, expires_at)
  values (p_type, pt, nullif(left(regexp_replace(coalesce(p_comment, ''), '[<>[:cntrl:]]', '', 'g'), 140), ''), uid, now() + v_ttl)
  returning id into new_id;
  return json_build_object('id', new_id, 'merged', false);
end $$;

-- ---------------------------------------------------------------------------
-- RPC : vote « Toujours présent » / « Plus présent » (1 vote par personne, pas sur son propre signalement)
-- ---------------------------------------------------------------------------
create or replace function public.vote_report(p_report uuid, p_vote text)
returns void language plpgsql security definer set search_path = public as $$
declare uid uuid := auth.uid(); r public.reports; v_ttl interval; remaining interval;
begin
  if uid is null then raise exception 'Connexion requise' using errcode = '28000'; end if;
  select * into r from public.reports where id = p_report for update;
  if not found then raise exception 'Signalement introuvable'; end if;
  if r.created_by = uid then return; end if;                       -- pas de vote sur son propre signalement (silencieux lors d'une fusion)
  insert into public.report_votes (report_id, user_id, vote) values (p_report, uid, p_vote)
    on conflict do nothing;
  if not found then raise exception 'Vous avez déjà donné votre avis' using errcode = 'P0001'; end if;
  select rt.ttl into v_ttl from public.report_types rt where rt.id = r.type;
  if p_vote = 'still' then
    update public.reports set confirms = confirms + 1,
      expires_at = least(greatest(expires_at, now()) + v_ttl * 0.5, now() + v_ttl * 2) where id = p_report;
  else
    remaining := greatest(r.expires_at - now(), interval '0');
    update public.reports set denies = denies + 1,
      expires_at = now() + remaining * (case when r.denies + 1 >= 2 then 0.25 else 0.6 end) where id = p_report;
  end if;
  update public.reports x set status = public.report_status(x) where x.id = p_report and x.status <> 'removed';
end $$;

-- RPC : alerte d'abus (masqué à 3 alertes)
create or replace function public.flag_report(p_report uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'Connexion requise' using errcode = '28000'; end if;
  insert into public.report_flags (report_id, user_id) values (p_report, auth.uid()) on conflict do nothing;
  if found then
    update public.reports set flags = flags + 1 where id = p_report;
    update public.reports x set status = public.report_status(x) where x.id = p_report and x.status <> 'removed';
  end if;
end $$;

-- RPC : retrait (auteur ou modérateur), journalisé
create or replace function public.remove_report(p_report uuid, p_reason text default 'author')
returns void language plpgsql security definer set search_path = public as $$
declare r public.reports;
begin
  select * into r from public.reports where id = p_report;
  if not found then return; end if;
  if r.created_by is distinct from auth.uid() and public.current_role_name() not in ('moderator', 'admin') then
    raise exception 'Action non autorisée' using errcode = '42501';
  end if;
  update public.reports set status = 'removed', removed_reason = left(p_reason, 60) where id = p_report;
  insert into public.moderation_log (report_id, actor, action, reason) values (p_report, auth.uid(), 'remove', left(p_reason, 60));
end $$;

-- ---------------------------------------------------------------------------
-- Établissements (ateliers, magasins, recharges) — source obligatoire
-- ---------------------------------------------------------------------------
create table if not exists public.businesses (
  id            text primary key,                    -- 'cur-strassride' ou 'osm-node/123'
  city_id       text references public.cities(id),
  name          text not null,
  category      text not null,
  kinds         text[] not null default '{}',
  services      text[] not null default '{}',
  geom          geography(Point, 4326) not null,
  address       text,
  phone         text,
  website       text,
  opening_hours text,                                -- format OSM
  source        text not null,                       -- jamais de fiche sans source
  source_url    text,
  verified_at   date,
  trust         text not null default 'osm' check (trust in ('verified', 'osm', 'unverified')),
  updated_at    timestamptz not null default now()
);
create index if not exists businesses_geom_idx on public.businesses using gist (geom);

create table if not exists public.business_fixes (
  id bigint generated always as identity primary key,
  business_id text references public.businesses(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete set null,
  text text not null check (char_length(text) <= 400),
  status text not null default 'pending' check (status in ('pending', 'applied', 'rejected')),
  created_at timestamptz not null default now()
);

-- Avis natifs (phase 5) : un avis par personne et par établissement
create table if not exists public.business_reviews (
  business_id text references public.businesses(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  rating smallint not null check (rating between 1 and 5),
  text text check (char_length(text) <= 600),
  created_at timestamptz not null default now(),
  primary key (business_id, user_id)
);

-- ---------------------------------------------------------------------------
-- Données personnelles : favoris et historique (opt-in, sans trace GPS)
-- ---------------------------------------------------------------------------
create table if not exists public.saved_places (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  kind text not null check (kind in ('home', 'work', 'favorite')),
  label text not null check (char_length(label) <= 120),
  geom geography(Point, 4326) not null,
  created_at timestamptz not null default now()
);
create table if not exists public.trips (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  destination_label text not null,
  distance_m int not null,
  duration_s int not null,
  profile text not null,
  created_at timestamptz not null default now()
  -- v0.1 : aucune géométrie. v0.2 : colonne track optionnelle (voir fin du fichier), uniquement sur consentement
);

-- ---------------------------------------------------------------------------
-- Sécurité : Row Level Security partout
-- ---------------------------------------------------------------------------
alter table public.profiles         enable row level security;
alter table public.reports          enable row level security;
alter table public.report_votes     enable row level security;
alter table public.report_flags     enable row level security;
alter table public.moderation_log   enable row level security;
alter table public.businesses       enable row level security;
alter table public.business_fixes   enable row level security;
alter table public.business_reviews enable row level security;
alter table public.saved_places     enable row level security;
alter table public.trips            enable row level security;
alter table public.cities           enable row level security;
alter table public.report_types     enable row level security;

-- Lecture publique des référentiels
create policy "cities_read" on public.cities for select using (true);
create policy "types_read" on public.report_types for select using (true);
create policy "biz_read" on public.businesses for select using (true);
create policy "reviews_read" on public.business_reviews for select using (true);

-- Profils : chacun lit et modifie le sien (le rôle n'est pas modifiable par l'utilisateur)
create policy "profile_self_read" on public.profiles for select using (id = auth.uid() or public.current_role_name() in ('moderator', 'admin'));
create policy "profile_self_update" on public.profiles for update using (id = auth.uid())
  with check (id = auth.uid() and role = (select role from public.profiles where id = auth.uid()) and trust = (select trust from public.profiles where id = auth.uid()));

-- Signalements : lecture des visibles ; écriture uniquement via les RPC (security definer)
create policy "reports_read" on public.reports for select using (status in ('active', 'confirmed', 'disputed') or public.current_role_name() in ('moderator', 'admin'));
create policy "votes_self" on public.report_votes for select using (user_id = auth.uid());
create policy "modlog_mod" on public.moderation_log for select using (public.current_role_name() in ('moderator', 'admin'));

-- Données personnelles : strictement privées
create policy "places_own" on public.saved_places for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "trips_own" on public.trips for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "fixes_insert" on public.business_fixes for insert with check (user_id = auth.uid());
create policy "fixes_mod" on public.business_fixes for select using (public.current_role_name() in ('moderator', 'admin') or user_id = auth.uid());
create policy "reviews_own" on public.business_reviews for insert with check (user_id = auth.uid());

-- Les RPC sont les seules portes d'écriture sur les signalements
revoke all on function public.create_report(text, float8, float8, text) from public;
revoke all on function public.vote_report(uuid, text) from public;
revoke all on function public.flag_report(uuid) from public;
revoke all on function public.remove_report(uuid, text) from public;
grant execute on function public.create_report(text, float8, float8, text) to authenticated;
grant execute on function public.vote_report(uuid, text) to authenticated;
grant execute on function public.flag_report(uuid) to authenticated;
grant execute on function public.remove_report(uuid, text) to authenticated;
grant execute on function public.reports_in_bbox(float8, float8, float8, float8) to anon, authenticated;

-- ---------------------------------------------------------------------------
-- Temps réel (WebSocket Supabase Realtime) sur les signalements
-- ---------------------------------------------------------------------------
alter publication supabase_realtime add table public.reports;

-- ---------------------------------------------------------------------------
-- Tâches planifiées : expiration toutes les 5 min, purge RGPD quotidienne
-- ---------------------------------------------------------------------------
select cron.schedule('voltgo-expire', '*/5 * * * *',
  $$update public.reports set status = 'expired' where status in ('active', 'confirmed', 'disputed') and expires_at <= now()$$);
select cron.schedule('voltgo-purge', '17 3 * * *',
  $$delete from public.reports where expires_at < now() - interval '7 days'$$);

-- Fiabilité des auteurs : part de signalements confirmés (min. 3 signalements)
select cron.schedule('voltgo-trust', '31 3 * * *', $$
  update public.profiles p set trust = s.t from (
    select created_by, round(avg(case when confirms > denies then 1 else 0 end)::numeric, 2) as t
    from public.reports where created_by is not null group by created_by having count(*) >= 3) s
  where p.id = s.created_by$$);

-- ===========================================================================
-- v0.2 : fiche véhicule et historique de trajets avec tracé (consentement)
-- Pas encore utilisé par l'app (données locales en v0.2) : prêt pour la synchro.
-- ===========================================================================
create table if not exists public.vehicles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  kind text not null default 'scooter' check (kind in ('scooter', 'ebike')),
  brand text check (char_length(brand) <= 40),
  model text check (char_length(model) <= 80),
  voltage_v numeric(5,1) check (voltage_v between 12 and 120),
  capacity_ah numeric(5,1) check (capacity_ah between 1 and 100),
  max_kmh int check (max_kmh between 5 and 25),        -- EDPM : 25 km/h maximum (R311-1)
  cruise_kmh int check (cruise_kmh between 5 and 25),
  motor_w int check (motor_w between 0 and 10000),
  ride_mode text check (ride_mode in ('eco', 'standard', 'sport')),
  weight_kg numeric(5,1),
  odometer_km int check (odometer_km >= 0),
  maintenance jsonb not null default '{}'::jsonb,       -- dates et km des derniers entretiens
  insurance jsonb not null default '{}'::jsonb,         -- assureur et échéance ; aucun numéro de contrat exigé
  updated_at timestamptz not null default now()
  -- volontairement : aucun numéro de série, aucune clé Bluetooth
);
create unique index if not exists vehicles_user_one on public.vehicles(user_id);

alter table public.trips add column if not exists max_kmh int;
alter table public.trips add column if not exists battery_start int check (battery_start between 0 and 100);
alter table public.trips add column if not exists battery_end int check (battery_end between 0 and 100);
alter table public.trips add column if not exists track geography(LineString, 4326);  -- seulement si l'utilisateur active « Enregistrer mes trajets »

alter table public.vehicles enable row level security;
create policy "vehicles_own" on public.vehicles for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Purge automatique des tracés de plus d'un an
select cron.schedule('voltgo-trips-purge', '43 3 * * *',
  $$update public.trips set track = null where track is not null and created_at < now() - interval '365 days'$$);


-- ===========================================================================
-- v0.3 : ordres préfectoraux de masquage (L130-11 / L130-12 / R130-12)
-- Saisis par un administrateur à réception de la réquisition. Lecture publique
-- (l'app filtre aussi côté client), écriture réservée au rôle admin.
-- ===========================================================================
create table if not exists public.blackouts (
  id uuid primary key default gen_random_uuid(),
  geom geography(Point, 4326) not null,
  lng float8 generated always as (ST_X(geom::geometry)) stored,
  lat float8 generated always as (ST_Y(geom::geometry)) stored,
  radius_m int not null check (radius_m between 100 and 20000),   -- 2 km en agglomération, 10 km hors agglomération (R130-12)
  starts_at timestamptz not null default now(),
  ends_at timestamptz not null,                                     -- 2 h (alcool, stupéfiants) ou 12 h selon la réquisition
  reference text,                                                   -- numéro de la réquisition préfectorale
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  check (ends_at > starts_at)
);
create index if not exists blackouts_active on public.blackouts (ends_at);
alter table public.blackouts enable row level security;
create policy "blackouts_read" on public.blackouts for select using (true);
create policy "blackouts_admin" on public.blackouts for all using (public.current_role_name() = 'admin') with check (public.current_role_name() = 'admin');

-- ===========================================================================
-- v0.3 : abonnements et paiements (écrits uniquement par le Worker, clé service_role)
-- ===========================================================================
create table if not exists public.subscriptions (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  plan text not null check (plan in ('essentiel', 'plus', 'express')),
  status text not null default 'active' check (status in ('active', 'cancelled', 'expired')),
  trial_started_at timestamptz,
  paid_at timestamptz,
  paid_until timestamptz,
  cancel_at timestamptz,
  last_order_id text,
  updated_at timestamptz not null default now()
);
create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  order_id text not null unique,
  plan text not null,
  kind text not null check (kind in ('subscription', 'cancel_fee')),
  amount_cents int not null check (amount_cents > 0),
  currency text not null default 'EUR',
  provider text not null default 'revolut',
  created_at timestamptz not null default now()
);
alter table public.subscriptions enable row level security;
alter table public.payments enable row level security;
-- Chacun lit son abonnement et ses paiements ; aucune écriture côté client (le Worker utilise service_role)
create policy "subs_own_read" on public.subscriptions for select using (user_id = auth.uid());
create policy "payments_own_read" on public.payments for select using (user_id = auth.uid());

-- Expiration quotidienne des abonnements échus
select cron.schedule('voltgo-subs-expire', '5 4 * * *',
  $$update public.subscriptions set status = 'expired', updated_at = now() where status = 'active' and paid_until is not null and paid_until < now()$$);
