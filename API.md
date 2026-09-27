# API

## 1. Services externes utilisés

| Service | Point d'accès | Usage | Conditions |
|---|---|---|---|
| OpenFreeMap | `tiles.openfreemap.org/styles/positron` (jour), `/styles/dark` (nuit) | Tuiles vectorielles, polices, sprites | Gratuit, sans clé ; attribution OpenMapTiles + OSM (automatique) |
| Valhalla FOSSGIS | `POST valhalla1.openstreetmap.de/route` | Itinéraires vélo, alternatives, instructions en français | Usage raisonnable ; en-tête `X-Client-Id` ; déclaration des apps publiques |
| Géoplateforme IGN | `GET data.geopf.fr/geocodage/search` et `/reverse` | Adresses (Base Adresse Nationale) | 50 requêtes/s/IP ; remplace `api-adresse.data.gouv.fr` (fermé en janvier 2026) |
| Photon (Komoot) | `GET photon.komoot.io/api/` | Lieux, gares, commerces | Usage raisonnable |
| Overpass | `POST overpass-api.de` → `maps.mail.ru` → `overpass.kumi.systems` | Ateliers, recharges, stations de gonflage, arrêts | Instances publiques souvent saturées : bascule + cache 24 h + instantané embarqué |
| Eurométropole de Strasbourg | `GET data.strasbourg.eu/api/explore/v2.1/catalog/datasets/amg_cycl_bnac/exports/geojson` | Aménagements cyclables (≈ 12 900 tronçons) | Open data ; chargé par cellules de 0,02° selon la vue |
| Strass&Go | `https://alphakorner.github.io/Strass-Go/` | Bouton « Besoin d'un bus ? » | Lien sortant (URL vérifiée) |
| AWS Terrain Tiles (Mapzen) | `https://elevation-tiles-prod.s3.amazonaws.com/terrarium/{z}/{x}/{y}.png` | Relief 3D (`setTerrain`) et ombrage (`hillshade`) en mode avancé | Open Data AWS, sans clé, encodage `terrarium`, zoom max 15 ; attribution affichée |
| OsmAnd | `https://osmand.net/go?lat=…&lon=…&z=17` | Ouvrir la destination dans OsmAnd | Lien sortant ; l'itinéraire complet passe par l'export GPX |
| Géoplateforme IGN (WMTS) | `https://data.geopf.fr/wmts?…LAYER=ORTHOIMAGERY.ORTHOPHOTOS&TILEMATRIXSET=PM&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}` | Vue satellite (bouton SAT) | Licence Ouverte, sans clé, France ; attribution affichée |
| Wikimedia Commons | `https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrnamespace=6&prop=imageinfo&iiprop=url\|extmetadata\|mime&origin=*` | Photo libre du modèle de trottinette (auteur et licence affichés) | API publique, CORS via `origin=*`, User-Agent de navigateur requis, usage raisonnable, cache 7 j |
| Eurométropole de Strasbourg — **calques v0.9** | `GET data.strasbourg.eu/api/explore/v2.1/catalog/datasets/<jeu>/exports/json|geojson?select=…&where=…` : `stations_tram` (102), `stationnement-velo` (5 685 arceaux), `stations-velhop` (40, occupation temps réel), `sirac_flux_trafic` (468 tronçons, état 0-3, toutes les 3 min), `programmation` (travaux de l'année, `where=annee=date'2026' and (metier='voirie' or metier="ouvrage d'art")`), `alertes-de-circulation` (`/records?limit=100`) | Tram & bus, arceaux, Vélhop, trafic, travaux & alertes | Licence Ouverte ; CORS `*` ; téléchargé **uniquement à l'activation du calque** ; cache 7 j (tram, arceaux), 24 h (travaux), 3 min (trafic), 2 min (Vélhop), 10 min (alertes) ; rafraîchi seulement carte visible |
| Open-Meteo | `GET api.open-meteo.com/v1/forecast?latitude&longitude&current=temperature_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m,wind_gusts_10m,is_day&hourly=precipitation_probability,…&forecast_hours=6` et `GET air-quality-api.open-meteo.com/v1/air-quality?current=european_aqi,pm2_5,pm10,nitrogen_dioxide,ozone` | Puce « Météo » sur la carte : température, vent, pluie à venir, indice européen de qualité de l'air, conseils trottinette | CC BY 4.0, sans clé, 10 000 requêtes/jour ; 2 appels toutes les 10 min, calque activé et carte visible seulement |
| Overpass (calques v0.9) | `node["amenity"="drinking_water"]` dans la requête principale (fontaines, cache 24 h + instantané embarqué) ; `node["highway"="bus_stop"]` **par cellule de vue de 0,01°** à zoom ≥ 15 (arrêts de bus, 12 cellules max par vue, une nouvelle tentative 10 s après un échec) | Fontaines, arrêts de bus | Instances publiques ; jamais toute l'Eurométropole d'un coup pour les arrêts |
| Revolut Merchant API | `https://sandbox-merchant.revolut.com` / `https://merchant.revolut.com` (`/api/orders`) | Paiement des forfaits, **uniquement depuis le Worker** (clé secrète) | Compte Revolut Business ; en-tête `Revolut-Api-Version: 2024-09-01` |

### Exemple : itinéraire trottinette

```http
POST /route
Content-Type: application/json
X-Client-Id: voltgo.alphakorner

{
  "locations": [{"lat":48.5839,"lon":7.7455,"type":"break"},{"lat":48.5850,"lon":7.7352,"type":"break"}],
  "costing": "bicycle",
  "costing_options": {"bicycle": {"bicycle_type":"Hybrid","cycling_speed":18,"use_roads":0.2,"use_hills":0.4,"avoid_bad_surfaces":0.7,"use_living_streets":0.6,"use_ferry":0}},
  "alternates": 2,
  "directions_options": {"units":"kilometers","language":"fr-FR"}
}
```

| Profil | `use_roads` | `avoid_bad_surfaces` | `cycling_speed` | Intention |
|---|---|---|---|---|
| Trottinette | 0,2 | 0,7 | 18 km/h | Privilégier les aménagements, éviter les revêtements dégradés |
| Vélo élec. | 0,45 | 0,4 | 22 km/h | Plus direct, dénivelé accepté |
| Prudent | 0 | 0,9 | 15 km/h | Maximiser les portions hors circulation générale |

| **EDPM perso** (mode avancé) | `(100 − évitement routes) / 100` | `évitement revêtements / 100` | réglable, **plafonné à 25 km/h** | Profil sur mesure ; `use_hills = (100 − évitement pentes) / 100`, `bicycle_type` au choix, option `shortest` |

Les profils ajustent les préférences du calcul. Ils n'encodent aucune règle de circulation : l'app rappelle de respecter la signalisation. Si une fiche véhicule existe, la vitesse du profil Trottinette prend la vitesse de croisière de la fiche, sans jamais dépasser 25 km/h.

### Styles d'itinéraire (v1.0)

Pour un même véhicule (`bicycle` costing), trois jeux d'options `costing_options.bicycle` : **Rapide** `use_roads .55, use_hills .8, avoid_bad_surfaces .3`, **Sûr** `use_roads .05, use_living_streets .95, avoid_bad_surfaces .6`, **Confort** `use_roads .15, use_hills .1, avoid_bad_surfaces .95`. Rapide et Sûr partent en parallèle à chaque recherche (`alternates: 0`), Confort seulement au toucher : **2 appels Valhalla par recherche** (au lieu de 1 appel + 2 alternatives), à déclarer tel quel à FOSSGIS.

### Dénivelé (v0.2)

Chaque requête ajoute `"elevation_interval": 30`. Valhalla renvoie alors `trip.legs[].elevation`, un tableau d'altitudes en mètres tous les 30 m le long du tracé. Côté app (fonctions pures de `logic.js`) :

- `elevationStats()` lisse les altitudes sur 5 points et applique un seuil d'hystérésis de 2 m. Sans ce traitement, le bruit du modèle de terrain donnait 22 m de D+ sur 1 km plat. La fonction renvoie D+, D−, altitudes min et max, pentes min et max, et la pente de chaque segment.
- `slopeColor()` colore le tracé selon la pente (`line-gradient` MapLibre, `lineMetrics: true`).
- `nextClimb()` détecte la prochaine montée d'au moins 5 % sur au moins 60 m. La navigation l'annonce à l'avance.
- `tripEnergy()` estime l'énergie : Wh/km de base (autonomie réelle, ou 70 % de l'autonomie constructeur) × facteur de mode (éco 0,85, standard 1, sport 1,25), plus l'énergie des montées `m·g·h / 0,65`. Le résultat est affiché en « % de batterie utilisés ».
- `toGPX()` produit un GPX 1.1 avec les altitudes.

Erreurs traduites : `442/443/170/171` → « Aucun itinéraire praticable… », `154` → « trajet trop long ».

### Calques de données (v0.9) : règles anti-saturation

- Rien n'est téléchargé tant que le calque est éteint ; les 5 filtres de base (pistes, signalements, recharge, ateliers, gonflage) restent les seuls visibles dans la rangée, les calques avancés n'y apparaissent que lorsqu'ils sont actifs, et la puce « Calques » ouvre le panneau complet.
- Couches denses rendues par MapLibre (sources GeoJSON, pas de DOM) : arceaux **regroupés en clusters** (`clusterRadius` 46 px, somme des places) et visibles dès le zoom 13, points détaillés dès le zoom 14 ; arrêts de bus dès le zoom 15 et chargés **pour la vue courante seulement** ; libellés optionnels (`text-optional`) pour ne jamais masquer le fond.
- Flux temps réel (trafic SIRAC 3 min, Vélhop 2 min, météo 10 min) : minuteries démarrées à l'activation, **suspendues** quand l'onglet est caché ou qu'on quitte l'écran carte, arrêtées à la désactivation.
- Les arceaux sont stockés sous forme compacte `[lng, lat, places, abri]` (≈ 150 ko pour 5 685 points) dans `localStorage` pendant 7 jours ; le trafic et les stations Vélhop ne sont jamais persistés.
- Les couches sont insérées **au-dessus des routes et bâtiments** mais sous les libellés : `MapView.firstSymbolLayer()` choisit la première couche `symbol` placée après la dernière couche de voirie (le style `dark` d'OpenFreeMap met `water_name` avant les routes, ce qui cachait autrefois les tracés sous la voirie en mode nuit — corrigé en v0.9).

## 1 bis. Données de la trottinette : saisie client, aucune connexion

Aucun constructeur ne publie d'API ou de SDK pour les tiers ; les protocoles Bluetooth communautaires ne fonctionnent que sur de vieux firmwares non chiffrés. La v0.4 a donc **retiré toute connexion** : la fiche demande la tension (V), la capacité (Ah), les autonomies annoncée et constatée, le niveau, le compteur, la distance voulue et le chargeur. Le calcul est local (`Logic.rangePlan`) :

- énergie `Wh = V × Ah`, dont 90 % utilisables (réserve de sécurité) ;
- consommation `Wh/km` = Wh ÷ autonomie constatée (à défaut 70 % de l'annoncée), × facteur de mode (éco 0,85, standard 1, sport 1,25) ;
- km possibles maintenant = Wh disponibles au niveau saisi ÷ Wh/km ; km sur batterie pleine ; Wh et % nécessaires pour les km voulus ; faisable ou non, km manquants ;
- temps de recharge ≈ Wh ÷ (V × A du chargeur) × 1,15.

Le carnet d'entretien (`Carnet`) enregistre les interventions et remet les rappels à zéro (`vehicle.maint`).

## 1 ter. Paiement Revolut (v0.3) — routes `/billing/*` du Worker

Le client ne parle jamais à Revolut directement : la clé secrète reste dans le Worker.

| Route | Méthode | Corps / paramètres | Réponse |
|---|---|---|---|
| `/billing/order` | POST | `{ plan: 'essentiel'\|'plus'\|'express', kind: 'subscription'\|'cancel_fee', userId, email, redirect }` | `{ orderId, checkoutUrl }` — l'app redirige vers `checkoutUrl` (page de paiement hébergée Revolut : carte, Apple Pay, Google Pay, Revolut Pay) |
| `/billing/status` | GET | `?order=<orderId>` | `{ state: 'PENDING'\|'COMPLETED'\|'FAILED', token?, plan }` — interroge Revolut si le webhook n'est pas encore passé |
| `/billing/webhook` | POST | Évènement Revolut `ORDER_COMPLETED` | Vérifie `Revolut-Signature` (`v1=` + HMAC-SHA256 du message `v1.{timestamp}.{corps}`), tolérance 5 min, puis émet le jeton |

**Jeton** : `vg1.<base64url(JSON)>.<base64url(HMAC-SHA256)>` avec `{ plan, kind, paidAt, paidUntil, orderId, sub }`. Le client le stocke et l'applique (`Billing.applyToken`) ; le Worker écrit aussi `subscriptions` et `payments` dans Supabase (clé `service_role`) quand `SUPABASE_URL` et `SUPABASE_SERVICE_KEY` sont renseignés. Sans Worker, l'app émet un jeton **DÉMO** (`.demo`) qui n'a aucune valeur de paiement.

**Montants** (centimes, TTC) : `essentiel 499`, `plus 589`, `express 949` ; frais de désinscription = 1 mois du forfait (`CANCEL_FEE_MONTHS`). Cycle : 29 jours.

**Retour dans l'app** : `redirect_url = <app>#pay=return`. Au chargement, `Billing.handleReturn()` retrouve la commande en attente (`pay:pending`) et interroge `/billing/status` jusqu'à confirmation.

## 2. RPC Supabase (appelées par `SupabaseDataProvider`)

Toutes via `supabase.rpc(nom, paramètres)`, authentifiées par le JWT de session.

| RPC | Paramètres | Retour | Règles |
|---|---|---|---|
| `reports_in_bbox` | `min_lng, min_lat, max_lng, max_lat` | lignes : id, type, lng, lat, comment, created_by, author_name, author_trust, created_at, expires_at, confirms, denies, flags, status | Visibles seulement, 500 max, accessible sans compte |
| `create_report` | `p_type, p_lng, p_lat, p_comment` | `{ id, merged }` | Compte requis ; ville couverte ; 45 s entre deux ; 8/h ; doublon < 50 m → confirmation |
| `vote_report` | `p_report, p_vote ('still'\|'gone')` | — | 1 vote/personne ; pas sur son propre signalement ; ajuste `expires_at` |
| `flag_report` | `p_report` | — | 1 alerte/personne ; masqué à 3 |
| `remove_report` | `p_report, p_reason` | — | Auteur ou modérateur ; journalisé dans `moderation_log` |

Temps réel : `postgres_changes` sur `public.reports` (publication `supabase_realtime`).

Masquage préfectoral (v0.3) : `reports_in_bbox` exclut tout signalement de type `controle` situé dans le rayon d'une ligne active de `public.blackouts`. Le client lit aussi `blackouts` (`listBlackouts`) pour filtrer ce qui arrive en temps réel.

Tâches `pg_cron` : expiration toutes les 5 min, purge RGPD à J+7, recalcul de la fiabilité des auteurs chaque nuit.

## 3. Routes du Worker (`worker-proxy.js`)

| Route | Méthode | Cible | Cache |
|---|---|---|---|
| `/route` | POST | Valhalla (+ `X-Client-Id`) | aucun |
| `/geocode` | GET | Géoplateforme `search` | 24 h |
| `/reverse` | GET | Géoplateforme `reverse` | 24 h |
| `/photon` | GET | Photon | 24 h |
| `/overpass` | POST | 3 instances en bascule | 6 h (clé = empreinte SHA-256 de la requête) |
| `/health` | GET | — (indique `billing: true` si Revolut est configuré) | — |
| `/billing/order`, `/billing/status`, `/billing/webhook` | POST / GET / POST | Revolut Merchant API + KV | aucun |

Réponses d'erreur JSON en français ; `429` au-delà de 60 requêtes/minute/IP ; en-tête `X-VoltGo-Cache: HIT|MISS|BYPASS`.

## 4. Interface `DataProvider` (front)

Pour remplacer la démo par un autre backend (Node/Express + PostGIS par exemple), il suffit d'implémenter :

```js
listReports() → Promise<Report[]>
createReport(user, { type, lng, lat, comment }) → Promise<{ merged, report }>
vote(user, id, 'still' | 'gone') → Promise
flag(user, id) → Promise
remove(user, id, reason) → Promise
myVote(user, id) → 'still' | 'gone' | null
purgeExpired() → Promise
```
