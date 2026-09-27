/* Volt&Go — service worker
   Stratégie : l'app (index.html) en « réseau d'abord, cache en secours » pour
   toujours servir la dernière version ; les bibliothèques et polices en cache ;
   les API (itinéraires, recherche, signalements) jamais en cache : une donnée
   périmée ne doit pas passer pour une donnée fraîche. */
const VERSION = 'voltgo-v1.0.0';
const SHELL = ['./', './index.html', './manifest.webmanifest', './icon.svg'];
const STATIC_HOSTS = ['cdn.jsdelivr.net', 'cdnjs.cloudflare.com', 'fonts.googleapis.com', 'fonts.gstatic.com'];
const TILE_HOST = 'tiles.openfreemap.org';

self.addEventListener('install', e => {
  e.waitUntil(caches.open(VERSION).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => !k.startsWith(VERSION)).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  // 1. Coquille de l'app : réseau d'abord
  if (url.origin === location.origin) {
    e.respondWith(fetch(req).then(res => { const copy = res.clone(); caches.open(VERSION).then(c => c.put(req, copy)); return res; }).catch(() => caches.match(req).then(r => r || caches.match('./index.html'))));
    return;
  }
  // 2. Bibliothèques et polices versionnées : cache d'abord
  if (STATIC_HOSTS.includes(url.hostname)) {
    e.respondWith(caches.match(req).then(r => r || fetch(req).then(res => { const copy = res.clone(); caches.open(VERSION + '-static').then(c => c.put(req, copy)); return res; })));
    return;
  }
  // 3. Tuiles de carte : cache limité pour garder la carte visible hors ligne
  if (url.hostname === TILE_HOST) {
    e.respondWith(caches.open(VERSION + '-tiles').then(async c => {
      const hit = await c.match(req);
      const net = fetch(req).then(res => { if (res.ok) { c.put(req, res.clone()); trim(c, 1500); } return res; }).catch(() => hit);
      return hit || net;
    }));
  }
  // 4. Tout le reste (API) : réseau uniquement
});
async function trim(cache, max) {
  const keys = await cache.keys();
  if (keys.length > max) for (const k of keys.slice(0, keys.length - max)) await cache.delete(k);
}
