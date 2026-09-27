/* ==========================================================================
   Volt&Go — Proxy Cloudflare Worker (gratuit : 100 000 requêtes/jour)
   Rôle : un seul point d'entrée pour les API publiques, avec
   - en-tête X-Client-Id demandé par FOSSGIS (Valhalla) ;
   - cache (recherche 24 h, points d'intérêt 6 h) pour ménager les serveurs gratuits ;
   - bascule automatique entre instances Overpass ;
   - CORS limité à vos domaines ;
   - limitation simple par IP (complétez avec une règle « Rate limiting » Cloudflare).
   Déploiement : voir DEPLOIEMENT.md (copier-coller dans le tableau de bord Cloudflare).
   Variables (Settings > Variables) :
     ALLOWED_ORIGINS = https://alphakorner.github.io,http://localhost:8765
     CLIENT_ID       = voltgo.alphakorner (identifiant déclaré à FOSSGIS)
   ========================================================================== */
const UPSTREAM = {
  route: 'https://valhalla1.openstreetmap.de/route',
  geocode: 'https://data.geopf.fr/geocodage/search',
  reverse: 'https://data.geopf.fr/geocodage/reverse',
  photon: 'https://photon.komoot.io/api/',
  overpass: ['https://overpass-api.de/api/interpreter', 'https://maps.mail.ru/osm/tools/overpass/api/interpreter', 'https://overpass.kumi.systems/api/interpreter']
};
const TTL = { geocode: 86400, reverse: 86400, photon: 86400, overpass: 21600, route: 0 };
const LIMIT_PER_MIN = 60;           // par IP et par instance du Worker
const hits = new Map();

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const origin = request.headers.get('Origin') || '';
    const allowed = (env.ALLOWED_ORIGINS || '').split(',').map(s => s.trim()).filter(Boolean);
    const cors = {
      'Access-Control-Allow-Origin': allowed.includes(origin) ? origin : (allowed[0] || '*'),
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, X-Client-Id',
      'Access-Control-Max-Age': '86400',
      'Vary': 'Origin'
    };
    if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors });
    if (allowed.length && origin && !allowed.includes(origin)) return json({ error: 'Origine non autorisée' }, 403, cors);

    // Limitation par IP (meilleur effort : la mémoire est propre à chaque instance)
    const ip = request.headers.get('CF-Connecting-IP') || 'inconnue';
    const minute = Math.floor(Date.now() / 60000);
    const key = ip + ':' + minute;
    const n = (hits.get(key) || 0) + 1; hits.set(key, n);
    if (hits.size > 5000) for (const k of hits.keys()) if (!k.endsWith(':' + minute)) hits.delete(k);
    if (n > LIMIT_PER_MIN) return json({ error: 'Trop de requêtes, réessayez dans une minute.' }, 429, { ...cors, 'Retry-After': '60' });

    const name = url.pathname.replace(/^\/+/, '').split('/')[0];
    if (name === 'health') return json({ ok: true, at: new Date().toISOString(), billing: !!env.REVOLUT_SECRET_KEY }, 200, cors);
    if (name === 'billing') return billing(request, env, ctx, url, cors);
    if (!(name in UPSTREAM)) return json({ error: 'Route inconnue', routes: Object.keys(UPSTREAM) }, 404, cors);

    try {
      let res;
      if (name === 'route') {
        if (request.method !== 'POST') return json({ error: 'POST attendu' }, 405, cors);
        const body = await request.text();
        if (body.length > 20000) return json({ error: 'Requête trop grande' }, 413, cors);
        res = await fetch(UPSTREAM.route, { method: 'POST', body, headers: { 'Content-Type': 'application/json', 'X-Client-Id': env.CLIENT_ID || 'voltgo', 'User-Agent': 'VoltGo-proxy (+https://alphakorner.github.io)' } });
      } else if (name === 'overpass') {
        const body = request.method === 'POST' ? await request.text() : 'data=' + encodeURIComponent(url.searchParams.get('data') || '');
        if (body.length > 8000) return json({ error: 'Requête trop grande' }, 413, cors);
        const cacheKey = new Request('https://cache.voltgo/overpass/' + await sha256(body));
        const cached = await caches.default.match(cacheKey);
        if (cached) return withCors(cached, cors, 'HIT');
        for (const up of UPSTREAM.overpass) {
          try {
            const r = await fetch(up, { method: 'POST', body, headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'User-Agent': 'VoltGo-proxy (+https://alphakorner.github.io)' } });
            if (r.ok) { res = r; break; }
          } catch (e) { /* instance suivante */ }
        }
        if (!res) return json({ error: 'Overpass indisponible' }, 503, cors);
        const out = new Response(res.body, res); out.headers.set('Cache-Control', 'public, max-age=' + TTL.overpass);
        ctx.waitUntil(caches.default.put(cacheKey, out.clone()));
        return withCors(out, cors, 'MISS');
      } else {
        // GET avec cache (recherche d'adresses et de lieux)
        const target = UPSTREAM[name] + url.search;
        const cacheKey = new Request(target);
        const cached = await caches.default.match(cacheKey);
        if (cached) return withCors(cached, cors, 'HIT');
        res = await fetch(target, { headers: { 'User-Agent': 'VoltGo-proxy (+https://alphakorner.github.io)' } });
        if (res.ok && TTL[name]) {
          const out = new Response(res.body, res); out.headers.set('Cache-Control', 'public, max-age=' + TTL[name]);
          ctx.waitUntil(caches.default.put(cacheKey, out.clone()));
          return withCors(out, cors, 'MISS');
        }
      }
      return withCors(res, cors, 'BYPASS');
    } catch (e) {
      return json({ error: 'Service amont injoignable', detail: String(e && e.message || e) }, 502, cors);
    }
  }
};

function withCors(res, cors, cache) {
  const out = new Response(res.body, res);
  for (const [k, v] of Object.entries(cors)) out.headers.set(k, v);
  out.headers.set('X-VoltGo-Cache', cache);
  return out;
}
function json(obj, status, headers) {
  return new Response(JSON.stringify(obj), { status, headers: { ...headers, 'Content-Type': 'application/json; charset=utf-8' } });
}
async function sha256(s) {
  const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(s));
  return [...new Uint8Array(buf)].map(b => b.toString(16).padStart(2, '0')).join('');
}


/* ===========================================================================
   Abonnements (v0.3) — Revolut Merchant API, page de paiement hébergée.
   Variables du Worker (wrangler secret put …) :
     REVOLUT_SECRET_KEY   clé secrète Merchant API (sandbox : sk_… du compte sandbox)
     REVOLUT_ENV          'sandbox' (défaut) ou 'production'
     REVOLUT_WEBHOOK_SECRET  signing secret renvoyé à la création du webhook (vérification Revolut-Signature)
     BILLING_SECRET       secret HMAC du jeton renvoyé à l'app (32+ caractères aléatoires)
     BILLING_KV           (binding KV) stockage orderId → { plan, kind, userId, state, token }
     SUPABASE_URL / SUPABASE_SERVICE_KEY (facultatif) : écriture dans la table subscriptions
   Routes :
     POST /billing/order   { plan, kind, userId, email, redirect } → { orderId, checkoutUrl }
     GET  /billing/status?order=… → { state, token? }
     POST /billing/webhook (appelé par Revolut : ORDER_COMPLETED)
   =========================================================================== */
const PLANS = { essentiel: 499, plus: 589, express: 949 };  // centimes, TTC
const CYCLE_DAYS = 29, CANCEL_FEE_MONTHS = 1;
const REVOLUT = { sandbox: 'https://sandbox-merchant.revolut.com', production: 'https://merchant.revolut.com' };
async function billing(request, env, ctx, url, cors) {
  const sub = url.pathname.split('/')[2] || '';
  if (!env.REVOLUT_SECRET_KEY || !env.BILLING_SECRET || !env.BILLING_KV) return json({ error: 'Paiement non configuré sur ce Worker (REVOLUT_SECRET_KEY, BILLING_SECRET, BILLING_KV).' }, 501, cors);
  const base = REVOLUT[env.REVOLUT_ENV === 'production' ? 'production' : 'sandbox'];
  const api = (path, init = {}) => fetch(base + path, { ...init, headers: { 'Authorization': 'Bearer ' + env.REVOLUT_SECRET_KEY, 'Revolut-Api-Version': '2024-09-01', 'Content-Type': 'application/json', ...(init.headers || {}) } });

  if (sub === 'order' && request.method === 'POST') {
    const b = await request.json().catch(() => ({}));
    const plan = PLANS[b.plan] ? b.plan : null; if (!plan) return json({ error: 'Forfait inconnu' }, 400, cors);
    const kind = b.kind === 'cancel_fee' ? 'cancel_fee' : 'subscription';
    const amount = kind === 'cancel_fee' ? PLANS[plan] * CANCEL_FEE_MONTHS : PLANS[plan];
    const r = await api('/api/orders', { method: 'POST', body: JSON.stringify({ amount, currency: 'EUR', description: kind === 'cancel_fee' ? `Volt&Go — frais de dossier de désinscription (${plan})` : `Volt&Go — forfait ${plan} (${CYCLE_DAYS} jours)`, customer: b.email ? { email: b.email } : undefined, redirect_url: b.redirect, metadata: { userId: String(b.userId || ''), plan, kind } }) });
    if (!r.ok) return json({ error: 'Revolut a refusé la création de la commande', detail: await r.text() }, 502, cors);
    const o = await r.json();
    await env.BILLING_KV.put('order:' + o.id, JSON.stringify({ plan, kind, userId: b.userId, state: 'PENDING', at: Date.now() }), { expirationTtl: 86400 * 3 });
    return json({ orderId: o.id, checkoutUrl: o.checkout_url }, 200, cors);
  }
  if (sub === 'status') {
    const id = url.searchParams.get('order') || '';
    const rec = JSON.parse((await env.BILLING_KV.get('order:' + id)) || 'null');
    if (!rec) return json({ state: 'UNKNOWN' }, 404, cors);
    if (rec.state !== 'COMPLETED') {
      // Le webhook n'est pas encore passé : on interroge Revolut directement
      const r = await api('/api/orders/' + id); if (r.ok) { const o = await r.json(); if (o.state === 'completed') await complete(env, id, rec); else if (['cancelled', 'failed'].includes(o.state)) rec.state = 'FAILED'; }
      const again = JSON.parse((await env.BILLING_KV.get('order:' + id)) || 'null'); if (again) Object.assign(rec, again);
    }
    return json({ state: rec.state, token: rec.state === 'COMPLETED' ? rec.token : undefined, plan: rec.plan }, 200, cors);
  }
  if (sub === 'webhook' && request.method === 'POST') {
    const raw = await request.text();
    if (env.REVOLUT_WEBHOOK_SECRET) {
      // Signature : v1=HMAC-SHA256(secret, "v1.{timestamp}.{payload}") dans Revolut-Signature, horodatage dans Revolut-Request-Timestamp
      const ts = request.headers.get('Revolut-Request-Timestamp') || '', sig = request.headers.get('Revolut-Signature') || '';
      const expected = 'v1=' + await hmacHex(env.REVOLUT_WEBHOOK_SECRET, `v1.${ts}.${raw}`);
      if (!sig.split(',').map(x => x.trim()).includes(expected) || Math.abs(Date.now() - Number(ts)) > 5 * 60e3) return json({ error: 'Signature invalide' }, 401, cors);
    }
    const ev = JSON.parse(raw || '{}');
    if (ev.event === 'ORDER_COMPLETED' && ev.order_id) { const rec = JSON.parse((await env.BILLING_KV.get('order:' + ev.order_id)) || 'null'); if (rec) await complete(env, ev.order_id, rec); }
    return json({ ok: true }, 200, cors);
  }
  return json({ error: 'Route billing inconnue', routes: ['POST /billing/order', 'GET /billing/status', 'POST /billing/webhook'] }, 404, cors);
}
async function complete(env, orderId, rec) {
  if (rec.state === 'COMPLETED') return;
  const paidAt = Date.now();
  const payload = { plan: rec.plan, kind: rec.kind, paidAt, paidUntil: rec.kind === 'subscription' ? paidAt + CYCLE_DAYS * 86400e3 : null, orderId, sub: rec.userId };
  const p = b64url(JSON.stringify(payload));
  const token = 'vg1.' + p + '.' + b64url(await hmacRaw(env.BILLING_SECRET, p));
  await env.BILLING_KV.put('order:' + orderId, JSON.stringify({ ...rec, state: 'COMPLETED', token, paidAt }), { expirationTtl: 86400 * 40 });
  if (env.SUPABASE_URL && env.SUPABASE_SERVICE_KEY && rec.userId && rec.userId !== 'guest') {
    // Écriture serveur (service_role) : la RLS empêche l'utilisateur de modifier lui-même son abonnement
    await fetch(env.SUPABASE_URL + '/rest/v1/subscriptions', { method: 'POST', headers: { apikey: env.SUPABASE_SERVICE_KEY, Authorization: 'Bearer ' + env.SUPABASE_SERVICE_KEY, 'Content-Type': 'application/json', Prefer: 'resolution=merge-duplicates' },
      body: JSON.stringify({ user_id: rec.userId, plan: rec.plan, paid_at: new Date(paidAt).toISOString(), paid_until: payload.paidUntil ? new Date(payload.paidUntil).toISOString() : null, last_order_id: orderId, status: rec.kind === 'cancel_fee' ? 'cancelled' : 'active' }) }).catch(() => {});
    await fetch(env.SUPABASE_URL + '/rest/v1/payments', { method: 'POST', headers: { apikey: env.SUPABASE_SERVICE_KEY, Authorization: 'Bearer ' + env.SUPABASE_SERVICE_KEY, 'Content-Type': 'application/json' },
      body: JSON.stringify({ user_id: rec.userId, order_id: orderId, plan: rec.plan, kind: rec.kind, amount_cents: rec.kind === 'cancel_fee' ? PLANS[rec.plan] * CANCEL_FEE_MONTHS : PLANS[rec.plan], provider: 'revolut' }) }).catch(() => {});
  }
}
function b64url(x) { const s = typeof x === 'string' ? btoa(unescape(encodeURIComponent(x))) : btoa(String.fromCharCode(...new Uint8Array(x))); return s.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, ''); }
async function hmacRaw(secret, msg) { const k = await crypto.subtle.importKey('raw', new TextEncoder().encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']); return crypto.subtle.sign('HMAC', k, new TextEncoder().encode(msg)); }
async function hmacHex(secret, msg) { return [...new Uint8Array(await hmacRaw(secret, msg))].map(b => b.toString(16).padStart(2, '0')).join(''); }
