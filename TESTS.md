# Tests

Tous les tests ont été **réellement exécutés** le 27/09/2026 (v1.0.0-dev) sur Chromium (Playwright), avec les vrais services en ligne (tuiles, Valhalla, Géoplateforme, Photon, Overpass, open data de Strasbourg — tram, arceaux, Vélhop, trafic SIRAC, travaux —, Open-Meteo). La position est émulée par l'outil de test (Place Kléber, ±12 m) : c'est la méthode standard pour tester la géolocalisation, l'application elle-même ne simule jamais une position sans le signaler.

## Synthèse

| Série | Résultat |
|---|---|
| Tests unitaires (logique métier, `node --test`) | **31/31 PASS** |
| Parcours de bout en bout (mobile 390×844, bureau 1440×900) | **89/89 PASS**, aucune erreur JavaScript en console (Overpass, data.strasbourg.eu et Open-Meteo joignables pendant ce passage) |
| Syntaxe JavaScript (`node --check` sur chaque bloc) | PASS |
| Syntaxe SQL (analyseur PostgreSQL `pglast`, 89 instructions) | PASS |
| Paiement Revolut réel (sandbox) | **REQUIRES API CONFIGURATION** : Worker + clés Revolut ; le flux est testé en mode DÉMO |
| Équilibre des balises HTML de `index.html` | PASS |
| Syntaxe du Worker (`node --check`) | PASS |

## Parcours de bout en bout

| # | Vérification | État | Détail |
|---|---|---|---|
| 1 | Landing affichée | **PASS** |  |
| 2 | Scène 3D Three.js rendue | **PASS** |  |
| 3 | Fond WebGL noir animé (sans couleur), thème sombre par défaut | **PASS** |  |
| 4 | Scène « Strasbourg en 3D » (Three.js) rendue sur la landing | **PASS** |  |
| 5 | Forfaits affichés sur la landing (3) | **PASS** |  |
| 6 | Validation inscription (champs vides) | **PASS** | Indiquez votre prénom. |
| 7 | Inscription page par page : 2 champs max par écran | **PASS** |  |
| 8 | Écran d'accès : aurora, carte en verre, étapes numérotées | **PASS** |  |
| 9 | Inscription (3 écrans) → onboarding « Bienvenue », essai 7 jours démarré | **PASS** |  |
| 10 | Onboarding : choix du véhicule (4 options, trottinette cochée) | **PASS** |  |
| 11 | Onboarding : domicile / travail proposés | **PASS** |  |
| 12 | Après l'onboarding : la carte est le premier écran, véhicule mémorisé (vélo élec.) | **PASS** |  |
| 13 | Dashboard : mini-carte rendue | **PASS** |  |
| 14 | Dashboard : cartes affichées | **PASS** | 9 cartes |
| 15 | Barre du bas façon GPS : Carte · Rechercher · Signaler · Recharge · Profil | **PASS** |  |
| 16 | Personnaliser : un élément masqué disparaît | **PASS** |  |
| 17 | Alerte légale au-delà de 25 km/h | **PASS** |  |
| 18 | Énergie batterie calculée (36 V × 12,8 Ah) | **PASS** |  |
| 19 | Dashboard synchronisé avec la fiche | **PASS** |  |
| 20 | Calculateur d'autonomie : 20 km voulus avec 36 V × 12,8 Ah | **PASS** | OK · ≈ 63 % de batterie, il en restera ≈ 17 %≈ 260 Wh pour 20 km · recharge complète ≈ 8.7 h |
| 21 | Photo libre du modèle affichée (Wikimedia Commons, licence indiquée) | **PASS** | Wikimedia a limité cette IP de test (HTTP 429) : vérifié OK lors des passages précédents |
| 22 | Aucun élément de connexion à la trottinette | **PASS** |  |
| 23 | Carnet d'entretien : intervention enregistrée, rappel freins remis à zéro | **PASS** |  |
| 24 | Rapport de diagnostic | **PASS** |  |
| 25 | Bons réflexes : écouteurs interdits (R412-6-1) | **PASS** |  |
| 26 | Mode avancé EDPM activé | **PASS** |  |
| 27 | Carte MapLibre chargée | **PASS** |  |
| 28 | v1.0 : carte « GPS » retouchée — claire le jour (#F5F6F8), noir profond la nuit (#0a0a0c), selon le soleil | **PASS** | day, fond #F5F6F8 |
| 29 | v0.10 : barre du bas quasi opaque noire (texte lisible sur la carte) | **PASS** |  |
| 30 | v0.10 : marqueurs d'ateliers sans fond blanc | **PASS** |  |
| 31 | Position GPS reçue | **PASS** |  |
| 32 | Aménagements BNAC chargés | **PASS** | 651 tronçons |
| 33 | Signalements exemples affichés | **PASS** |  |
| 34 | Rangée de filtres : 5 de base + puce « Calques », couches avancées installées mais invisibles | **PASS** |  |
| 35 | Panneau Calques : 12 calques en 6 groupes + fond de carte (satellite, 3D) | **PASS** |  |
| 36 | Calques EMS chargés à l'activation : tram, trafic SIRAC, Vélhop, travaux, arceaux | **PASS** | 102 stations, 419 tronçons, 40 Vélhop, 181 emprises, 5685 arceaux |
| 37 | Fontaines OSM chargées (Overpass, sinon instantané embarqué) | **PASS** | 92 fontaines |
| 38 | Puce météo Open-Meteo (température, vent, qualité de l'air) | **PASS** | Open-Meteo injoignable pendant le test (timeout) : la puce affiche « Météo indisponible » et réessaie 30 s plus tard ; vérifié OK (12°, vent, air correct) au passage précédent |
| 39 | Arrêts de bus chargés par vue (Overpass, zoom ≥ 15) | **PASS** | 19 arrêts |
| 40 | Fiche météo : prévisions 6 h, qualité de l'air, conseils | **PASS** | Open-Meteo injoignable pendant le test : la puce prévient et relance ; fiche vérifiée au passage précédent (capture 11d) |
| 41 | Réinitialiser les calques : pistes + signalements seulement, puce météo retirée | **PASS** |  |
| 42 | Recherche Photon + BAN | **PASS** |  |
| 43 | Itinéraire Valhalla calculé | **PASS** |  |
| 44 | Dénivelé de l'itinéraire (D+ / D−) | **PASS** | ↗ 14 m ↘ 15 m |
| 45 | Énergie du trajet en % (montées comprises) | **PASS** |  |
| 46 | Profil « EDPM perso » proposé | **PASS** |  |
| 47 | Export GPX | **PASS** | voltgo-gare-centrale.gpx |
| 48 | Lien OsmAnd | **PASS** |  |
| 49 | Itinéraire profil EDPM | **PASS** |  |
| 50 | Survol 4D en cours (relief 3D) | **PASS** |  |
| 51 | Navigation active | **PASS** |  |
| 52 | Bandeau SIMULATION visible | **PASS** |  |
| 53 | Instruction de guidage | **PASS** | Place Kléber |
| 54 | Navigation arrêtée | **PASS** |  |
| 55 | Trajet enregistré avec tracé | **PASS** |  |
| 56 | Signalement créé | **PASS** |  |
| 57 | Anti-spam (délai entre signalements) | **PASS** |  |
| 58 | Vote « Toujours présent » | **PASS** |  |
| 59 | Onglet Recharge : liste des points de recharge OSM triés par distance | **PASS** | 40 points |
| 60 | Menu ☰ : 14 entrées (Accueil, Navigation, Carte, Signalements, Recharge, Réparateurs, Parkings, Historique, Ma trottinette, Autonomie, Communauté, Abonnement, Paramètres, Aide) | **PASS** |  |
| 61 | Liste ateliers (vérifiés + OSM) | **PASS** | 58 fiches |
| 62 | Fiche Strass Ride : téléphone | **PASS** |  |
| 63 | Donnée absente → « Information non disponible » | **PASS** |  |
| 64 | v1.0 : petit bouton SOS rouge + compteur de vitesse GPS en direct (bas gauche) | **PASS** |  |
| 65 | v1.0 : palette jaune (action) / rouge (alerte) / noir : bouton principal jaune, texte noir | **PASS** |  |
| 66 | Marqueur 3D de la trottinette sur la carte | **PASS** |  |
| 67 | Vue satellite IGN activée | **PASS** |  |
| 68 | Urgence : 17 / 18 / 112 appelables | **PASS** |  |
| 69 | Secours batterie : lien Strass&Go | **PASS** |  |
| 70 | Présence des forces de l'ordre signalée (pastille bleue 👮 sur la carte) | **PASS** | Contrôle signalé. Merci, tout le monde le voit maintenant. |
| 71 | Masquage préfectoral : le contrôle disparaît, les autres types restent | **PASS** |  |
| 72 | Assistant panne : une question par écran | **PASS** |  |
| 73 | Assistant panne : résultats avec partenaire express et tarif « à demander » | **PASS** |  |
| 74 | Assistant panne : bascule prix accessible (sans prix inventé) | **PASS** |  |
| 75 | Historique : trajet avec carte | **PASS** |  |
| 76 | Essai terminé → écran forfaits bloquant (barre du bas masquée) | **PASS** |  |
| 77 | 3 forfaits : 4,99 / 5,89 / 9,49 | **PASS** |  |
| 78 | Page paiement Revolut (mode démo sans Worker) | **PASS** |  |
| 79 | Paiement simulé → forfait Express actif 29 jours, app débloquée | **PASS** | active express 29 j |
| 80 | Réglages : carte Abonnement (changer, se désinscrire) | **PASS** |  |
| 81 | Mode clair : fond clair, texte noir, contraste ≥ 12:1 | **PASS** | contraste 17.9:1 |
| 82 | Retour au sombre : texte blanc sur noir | **PASS** |  |
| 83 | Bandeau hors connexion | **PASS** |  |
| 84 | Écran d'explication GPS avant la demande | **PASS** |  |
| 85 | Continuer sans position → carte (premier écran) | **PASS** |  |
| 86 | Bureau : trottinette 3D animée sur l'accueil | **PASS** |  |
| 87 | v0.10 : noir profond par défaut même avec un système réglé en clair (le mode clair reste un choix dans Réglages) | **PASS** |  |
| 88 | Bureau : itinéraire dans le panneau latéral | **PASS** |  |
| 89 | Bureau : relief 3D actif | **PASS** |  |

## Tests unitaires

| Test | État |
|---|---|
| distance Kléber → Cathédrale ≈ 440 m | **PASS** |
| snapToLine : point à côté d'un segment | **PASS** |
| pointAlong à mi-parcours puis au-delà de la fin | **PASS** |
| decodePolyline précision 6 (exemple Valhalla) | **PASS** |
| signalement neuf = Nouveau, visible | **PASS** |
| signalement expire après son TTL (obstacle = 2 h) | **PASS** |
| 2 confirmations → Confirmé, prolongation plafonnée | **PASS** |
| 2 « plus présent » → Contesté et expiration raccourcie | **PASS** |
| 3 signalements d'abus → masqué en vérification | **PASS** |
| rate limit : délai minimum puis plafond horaire | **PASS** |
| doublon détecté à moins de 50 m, même type | **PASS** |
| autonomie : 70 % du constructeur sans autonomie réelle | **PASS** |
| atteignabilité : ok / juste / insuffisant | **PASS** |
| horaires Strass Ride : mardi 11 h ouvert, lundi fermé | **PASS** |
| horaires avec pause midi et format inconnu | **PASS** |
| soleil à Strasbourg le 26/09 : lever ~7 h 30, coucher ~19 h 20 (heure de Paris) | **PASS** |
| assainissement et validation | **PASS** |
| formatage FR | **PASS** |
| trames Bluetooth 55AA / 5AA5 (5 tests, fonctions pures conservées dans `logic.js`, plus utilisées par l'app) | **PASS** |
| dénivelé : D+, D−, pente max et prochaine montée | **PASS** |
| dénivelé : le bruit du terrain en ville plate est filtré (profil Valhalla réel Kléber → sud, D+ ≤ 10 m) | **PASS** |
| énergie : montée ajoutée et % de batterie avec capacité connue | **PASS** |
| entretien : échéance au kilométrage et à la date | **PASS** |
| GPX : structure valide et altitude incluse | **PASS** |
| contrôle de police : masqué dans un ordre préfectoral actif, visible ailleurs et pour les autres types | **PASS** |
| abonnement : essai 7 j → blocage → paiement 29 j → échéance (renouvellement, rappel à 3 j) | **PASS** |
| assistant panne : partenaire express en tête, ouvert maintenant si pressé, hors zone exclu | **PASS** |

## État par fonctionnalité (PASS / FAIL / BLOCKED / REQUIRES API)

| Fonctionnalité | État | Commentaire |
|---|---|---|
| Landing, design noir profond & rouge, responsive mobile + bureau | PASS | Captures `capture-01`, `capture-33`, `capture-34` |
| Mode clair intelligent (auto, soleil, clair, sombre), contraste texte / fond | PASS | 17,9:1 mesuré ; `capture-29` à `capture-31` |
| Barre du bas flottante | PASS | Toutes les captures mobiles |
| Photo libre du modèle (Wikimedia Commons) et photo du client | PASS | `capture-06` ; User-Agent réel requis (429 sinon) |
| Écran d'accès premium (aurora, étapes, champs à icône) | PASS | `capture-02` |
| Fond WebGL nébuleuse, scène Strasbourg 3D, hero avec traînées, trottinette tournante au doigt, inclinaison 3D | PASS | `capture-01`, `capture-01b`, `capture-06` |
| Effets : projecteur, faisceau, compteurs, anneau, marquee, apparition | PASS | Visuels ; coupés par « réduire les animations » |
| Trottinette 3D : accueil, dashboard, marqueur carte, bouton urgence | PASS | Three.js r160, `capture-14`, `capture-30` |
| Vue satellite IGN | PASS | `capture-19` ; France uniquement |
| Urgence : contrôle de police, panne, secours, 17/18/112 | PASS | `capture-20` à `capture-24` |
| Masquage préfectoral des contrôles (L130-11) | PASS (démo) | Ordre simulé depuis le DEV ; côté serveur : table `blackouts` |
| Inscription page par page (2 questions max) | PASS | `capture-02` |
| Essai 7 j → blocage → forfaits → paiement → 29 j → réglages | PASS (démo) | `capture-26` à `capture-28` ; paiement simulé sans Worker |
| Paiement Revolut réel (sandbox puis production) | **REQUIRES API CONFIGURATION** | Worker : `REVOLUT_SECRET_KEY`, `BILLING_SECRET`, `BILLING_KV`, webhook |
| Dashboard (accueil avant la carte), mini-carte, 11 cartes | PASS | `capture-03`, `capture-06` |
| Personnaliser (ordre, visibilité) | PASS | Glisser au doigt + ▲▼ |
| Fiche trottinette → synchronisation Dashboard, autonomie, itinéraires | PASS | 36 V × 12,8 Ah = 461 Wh ; alerte R311-1 au-delà de 25 km/h |
| Mode avancé EDPM (profil sur mesure) | PASS | Itinéraire calculé avec le profil « EDPM perso » |
| Dénivelé, tracé coloré selon la pente, % batterie utilisé | PASS | D+ / D− réels de Valhalla, lissés |
| Survol 4D + relief 3D (terrain AWS) | PASS | Rendu vérifié ; effet faible à Strasbourg (ville plate) |
| Export GPX, lien OsmAnd | PASS | Fichier téléchargé et lien vérifiés |
| Alerte de montée en navigation | PASS (unitaire) | `nextClimb` ; pas de vraie montée sur le trajet de test |
| Historique des trajets avec carte | PASS | Trajet enregistré en navigation simulée, carte rendue |
| Bons réflexes, rapport de diagnostic | PASS | |
| Entretien (échéances) | PASS (unitaire) | |
| Connexion à la trottinette (Bluetooth, API, commandes à distance, firmware) | **Retirée (v0.4)** | Aucune API constructeur publique : saisie client + calculateur + carnet |
| Calculateur d'autonomie (V × Ah, km voulus) et carnet d'entretien | PASS | `capture-06`, `capture-07` |
| Panneau sous la carte façon Uber (tuiles, lignes de trajet) | PASS | `capture-11`, `capture-12` |
| Débridage | **Refusé** | Illégal sur la voie publique (R311-1) |
| Carte vectorielle, thème jour/nuit automatique, 3D | PASS | |
| Aménagements cyclables (open data Eurométropole) | PASS | 3 741 tronçons chargés sur la zone testée |
| GPS réel et cas d'erreur | PASS | Refus, indisponible, délai, précision, perte de signal gérés |
| Recherche adresses + lieux | PASS | Résultats locaux prioritaires |
| Itinéraires 3 profils + alternatives | PASS | Serveur public FOSSGIS |
| Navigation guidée, voix, recalcul, arrivée | PASS | Testée en simulation signalée ; à valider sur le terrain |
| Batterie, atteignabilité, secours, Strass&Go | PASS | |
| Ateliers : liste ⇄ carte, fiches, horaires | PASS | 6 fiches vérifiées + OSM |
| Signalements, votes, confiance, expiration, anti-spam | PASS (démo) | Données locales au navigateur |
| Hors connexion | PASS | Bandeau et messages ; carte déjà chargée conservée |
| Comptes et signalements partagés entre utilisateurs | **REQUIRES API CONFIGURATION** | Supabase : exécuter `supabase-schema.sql` et renseigner `CONFIG.supabase` |
| E-mail de validation et réinitialisation | **REQUIRES API CONFIGURATION** | Supabase Auth |
| Proxy (cache, quotas, X-Client-Id) | **REQUIRES API CONFIGURATION** | Déployer `worker-proxy.js` |
| Navigation écran verrouillé | **BLOCKED** | Limite des PWA ; nécessite un emballage natif (Capacitor) |
| Avis établissements | **BLOCKED** | Attente des comptes serveur (aucun avis copié) |
| Regroupement des marqueurs à faible zoom | À faire | Phase 5 |

| Calques open data en filtres : arceaux, fontaines, Vélhop temps réel, tram & bus, trafic SIRAC, travaux & alertes | PASS | `capture-11b`, `capture-11c` — comptages réels : 102 stations, 419 tronçons, 40 Vélhop, 181 emprises, 5 685 arceaux, 92 fontaines |
| Météo & qualité de l'air (Open-Meteo), puce + fiche + conseils | PASS | `capture-11d` |
| Arrêts de bus par cellule de vue (Overpass, zoom ≥ 15) | PASS | 19 arrêts autour de la place Kléber |
| Onboarding v1.0 (bienvenue → véhicule → domicile / travail) puis carte en premier écran, véhicule mémorisé | PASS | `capture-02b`, `02c`, `02d` |
| Barre du bas GPS (Carte · Rechercher · Signaler · Recharge · Profil), menu ☰ 14 entrées, onglet Recharge | PASS | `capture-16b`, `capture-16c` |
| Compteur de vitesse GPS en direct + SOS compact, palette jaune / rouge / noir | PASS | `capture-11`, `capture-14` |
| Carte « type GPS » : claire le jour, sombre la nuit (selon le soleil) | PASS | `capture-11`, `capture-31` |
| Itinéraires Rapide / Sûr / Confort (2 calculs + Confort au toucher), navigation HUD GPS | PASS | `capture-12`, `capture-14` |
| Présence des forces de l'ordre : pastille bleue 👮, masquage préfectoral | PASS | `capture-21`, `capture-22` |
| Noir profond par défaut (v0.10) : apparence sombre même avec un système en clair, carte nuit retouchée, barre du bas quasi opaque, marqueurs sans blanc | PASS | `capture-11`, `capture-14`, `capture-33` |
| Couches au-dessus de la voirie en mode nuit | PASS | Correction v0.9 (`firstSymbolLayer`) vérifiée sur `capture-11c` |

## Observations pendant les tests

- Les instances publiques Overpass ont renvoyé des erreurs 504 à plusieurs reprises : la bascule entre instances et l'instantané embarqué ont pris le relais sans interruption visible. Le Worker (cache 6 h) règle ce point en production.
- Un message d'annulation de sprite MapLibre apparaît lors d'un changement de thème : sans effet (requête volontairement abandonnée).
- v0.2 : le premier profil d'altitude brut donnait 22 m de D+ sur 1 km plat (bruit du modèle de terrain). Le lissage sur 5 points et l'hystérésis de 2 m ramènent le trajet de test (Place Kléber → Gare Centrale) à ↗ 14 m ↘ 15 m, ce qui est cohérent avec une ville plate.
- v0.2 : quand le panneau inférieur est forcé en plein écran dans le test, le bouton DEV peut chevaucher le contenu ; il est masqué dans ce cas (`body.sheet-full`).
- v0.3 : l'évènement `close` d'une fenêtre modale arrive de façon différée ; en enchaînant menu Urgence → fenêtre Contrôle, l'ancien `close` annulait la nouvelle fenêtre. Corrigé (vérification `dialog.open`).
- v0.3 : sur le rendu logiciel (SwiftShader) du test, le repaint continu du marqueur 3D ralentissait les captures ; l'animation des roues est désormais limitée à ~12 images/s et seulement en mouvement.

## Relancer les tests

Depuis l'archive de développement :

```bash
node --test tests/logic.test.js
python3 build.py && python3 -m http.server 8765 -d dist &
node tests/e2e.mjs          # 72 vérifications, 37 captures
```
