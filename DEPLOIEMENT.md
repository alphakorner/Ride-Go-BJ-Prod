# Déploiement pas à pas

Trois étapes, dans cet ordre. Seule la première est obligatoire pour tester : les deux autres rendent l'app « production ».

---

## 1. GitHub Pages (obligatoire) — 5 min, depuis le téléphone

1. Sur github.com, créez un dépôt, par exemple `Volt-Go` (public).
2. **Add file → Upload files** : sélectionnez **tous les fichiers** de ce dossier d'un coup. Il n'y a aucun sous-dossier, l'envoi mobile fonctionne tel quel.
3. **Commit changes**.
4. **Settings → Pages** : Source = *Deploy from a branch*, Branch = `main`, dossier = `/ (root)` → **Save**.
5. Attendez 1 à 2 minutes : l'app est en ligne sur `https://alphakorner.github.io/Volt-Go/`.

Test rapide : ouvrez l'adresse sur le téléphone, créez un compte démo, autorisez la position, cherchez « Gare Centrale », lancez « Simuler le trajet ».

> Mise à jour : ré-uploadez seulement `index.html`. Le service worker sert toujours la dernière version en ligne (stratégie « réseau d'abord »).

> **Passage à la v1.0** : ré-uploadez tout (44 captures) ; le service worker passe à `voltgo-v1.0.0`. Avec Supabase, rejouez `supabase-schema.sql` (8 nouveaux types de signalement, `on conflict` : sans risque). Les comptes existants verront l'onboarding une fois.
>
> **Passage à la v0.10** : ré-uploadez tout ; le service worker passe à `voltgo-v0.10.0`. Les préférences déjà enregistrées sur un téléphone gardent leur apparence : pour retrouver le noir profond, Réglages → Apparence → Sombre.
>
> **Passage à la v0.9** : ré-uploadez tout (41 captures, supprimez les anciennes) ; le service worker passe à `voltgo-v0.9.0`. Les calques open data (data.strasbourg.eu) et la météo (Open-Meteo) sont appelés **directement depuis le navigateur** (CORS ouvert), sans passer par le Worker : rien à configurer.
>
> **Passage à la v0.8** : ré-uploadez tout (37 captures, supprimez les anciennes) ; le service worker passe à `voltgo-v0.8.0`.
>
> **Passage de la v0.1 à la v0.2** :
> 1. Supprimez les anciennes captures v0.1 : `capture-03-carte-batterie.png`, `capture-06-itineraire.png`, `capture-07-navigation.png`, etc. Les noms ont changé, et les nouvelles vont de `capture-01` à `capture-25`.
> 2. Ré-uploadez **tous** les fichiers : `index.html`, `sw.js`, `manifest.webmanifest`, `icon.svg`, les `.md`, les `.png` et `supabase-schema.sql`.
> 3. Le service worker passe à `voltgo-v0.2.0` et vide l'ancien cache tout seul.
>

---

## 2. Supabase (comptes et signalements réels) — 10 min

1. supabase.com → **New project** (nom : `voltgo`, région : *West EU (Paris)* ou *Central EU (Frankfurt)*).
2. **Database → Extensions** : activez `postgis` et `pg_cron`.
3. **SQL Editor → New query** : collez tout `supabase-schema.sql` → **Run**.
4. **Authentication → URL Configuration** :
   - *Site URL* : `https://alphakorner.github.io/Volt-Go/`
   - *Redirect URLs* : `https://alphakorner.github.io/Volt-Go/**` et `http://localhost:8765/**`
5. **Authentication → Emails → Confirm signup** : remplacez le texte par :
   > Bienvenue sur Volt&Go ! Confirmez votre adresse pour activer votre compte : {{ .ConfirmationURL }}
6. **Project Settings → API** : copiez *Project URL* et la clé *anon public*.
7. Dans `index.html`, cherchez `supabase: { url: '', anonKey: '' }` et collez les deux valeurs. Ré-uploadez `index.html`.

L'app bascule seule : le badge « Compte démo local » devient « Compte serveur », et le panneau DEV passe les lignes Auth / Signalements / Temps réel en **PASS**.

**Donner le rôle modérateur** (SQL Editor) :
```sql
update public.profiles set role = 'moderator' where id = (select id from auth.users where email = 'votre@email.fr');
```

> Offre gratuite Supabase : un projet sans activité peut être mis en pause. Le Worker de l'étape 3 peut le « réveiller » avec une tâche planifiée (option *Cron Triggers*).

---

## 3. Cloudflare Worker (proxy, cache, quotas) — 5 min

1. dash.cloudflare.com → **Workers & Pages → Create → Create Worker** → nom `voltgo-proxy` → **Deploy**.
2. **Edit code** : remplacez tout par le contenu de `worker-proxy.js` → **Deploy**.
3. **Settings → Variables and Secrets** :
   - `ALLOWED_ORIGINS` = `https://alphakorner.github.io,http://localhost:8765`
   - `CLIENT_ID` = `voltgo.alphakorner`
4. Test : ouvrez `https://voltgo-proxy.<votre-compte>.workers.dev/health` → `{"ok":true,…}`.
5. Dans `index.html` : `proxyBase: 'https://voltgo-proxy.<votre-compte>.workers.dev'` → ré-uploadez.
6. (Recommandé) **Security → WAF → Rate limiting rules** : 120 requêtes / minute / IP sur le Worker.

---

## 4. Déclarer l'app à FOSSGIS (Valhalla) — avant ouverture au public

FOSSGIS demande aux applications publiques de se déclarer. Ouvrez une discussion sur `github.com/valhalla/valhalla/discussions` avec ce texte :

> **Title:** Volt&Go — e-scooter / e-bike navigation PWA for Strasbourg (X-Client-Id: voltgo.alphakorner)
>
> Hello, we are building a free, non-commercial prototype navigation web app for e-scooter and e-bike riders in Strasbourg (France). It uses the public demo server for bicycle routing (`/route`, 1 route per user action, alternates ≤ 2, rerouting throttled to 1 per 12 s). All requests go through a caching proxy and send `X-Client-Id: voltgo.alphakorner`. Expected volume during the prototype phase: a few hundred requests per day. We plan to self-host Valhalla with a Grand Est extract before any commercial launch. Contact: strassweb67@gmail.com. Thank you for this service!

Pour un lancement commercial : Valhalla auto-hébergé (Docker `ghcr.io/valhalla/valhalla-scripted`, extrait Grand Est Geofabrik) sur votre Proxmox, puis `CONFIG.endpoints.valhalla` pointé dessus.

---

## Variables d'environnement (récapitulatif)

| Où | Clé | Valeur | Obligatoire |
|---|---|---|---|
| `index.html` → `CONFIG` | `supabase.url` | URL du projet | Non (démo sinon) |
| `index.html` → `CONFIG` | `supabase.anonKey` | Clé *anon public* (publique par nature, protégée par RLS) | Non |
| `index.html` → `CONFIG` | `proxyBase` | URL du Worker | Non (appels directs sinon) |
| `index.html` → `CONFIG` | `clientId` | Identifiant FOSSGIS | Oui en prod |
| Worker | `ALLOWED_ORIGINS` | Domaines autorisés, séparés par des virgules | Oui |
| Worker | `CLIENT_ID` | Identifiant FOSSGIS | Oui |

Ne mettez **jamais** la clé *service_role* de Supabase dans `index.html`.


---

## 4. Paiement Revolut (forfaits) — quand vous voulez encaisser pour de vrai

Sans cette étape, l'app fonctionne avec un **paiement simulé** (bouton violet « Simuler le paiement (DÉMO) ») : parfait pour tester, sans aucun débit.

1. Ouvrez un compte **Revolut Business** et activez **Merchant API** (Revolut Business → Merchant → API). Commencez en **sandbox** (`https://sandbox-business.revolut.com`).
2. Récupérez la **clé secrète** (Secret API key). Elle ne va **jamais** dans `index.html`, uniquement dans le Worker.
3. Dans Cloudflare, sur le Worker `voltgo-proxy` :
   - créez un espace **KV** et liez-le sous le nom `BILLING_KV` ;
   - secrets : `REVOLUT_SECRET_KEY` (clé Revolut), `BILLING_SECRET` (32 caractères aléatoires, ex. `openssl rand -hex 32`), `REVOLUT_ENV` = `sandbox` puis `production` ;
   - facultatif : `SUPABASE_URL` et `SUPABASE_SERVICE_KEY` (clé service_role, **jamais** côté client) pour que les paiements soient écrits dans `subscriptions` et `payments`.
4. Créez le **webhook** dans Revolut : URL = `https://voltgo-proxy.<compte>.workers.dev/billing/webhook`, évènement `ORDER_COMPLETED`. Copiez le *signing secret* dans le secret `REVOLUT_WEBHOOK_SECRET` du Worker.
5. Dans `index.html`, renseignez `proxyBase` avec l'URL du Worker. Ré-uploadez.
6. Test : Réglages → Abonnement → Voir les forfaits → Choisir → vous êtes redirigé vers la page de paiement Revolut (en sandbox, utilisez une carte de test Revolut). Au retour, l'app affiche « Forfait … activé ». `https://voltgo-proxy.<compte>.workers.dev/health` doit répondre `"billing": true`.
7. Passage en production : `REVOLUT_ENV=production` et la clé secrète de production ; recréez le webhook côté production.

**Ce que fait le jeton** : le Worker signe (HMAC-SHA256, `BILLING_SECRET`) un jeton `vg1.<données>.<signature>` qui contient le forfait choisi, la date de paiement et la date d'échéance. C'est ce jeton qui débloque le compte et qui vous dit quel forfait a été pris. Avec Supabase, la même information est écrite en base par le Worker.

**Avant d'encaisser** : mentions légales complètes (SIRET, TVA), CGU validées (dont l'article 9 sur les frais de désinscription : voir LEGAL-RGPD.md), et déclaration de l'adresse de contact pour les réquisitions préfectorales (contrôles de police).
