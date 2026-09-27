# Journal des modifications

## v1.0.0-dev — 27/09/2026 — « Volt&Go Navigator » : l'expérience GPS communautaire, palette jaune / rouge / noir

Brief : *« Mets 3 couleurs jaune, rouge et noir, pas que du rouge partout ; améliore le design comme Waze ; une page qui demande quel type de trott ; même type de carte ; mode carte 4D ; patrouilles de police dessinées et signalables ; une vraie barre de nav en bas ; un menu déroulant à gauche ; la vitesse GPS en direct en bas à gauche ; le bouton signalement au centre de la barre ; police / urgence en petit »* + le cahier des charges joint (22 points). Logique UX inspirée des GPS communautaires, identité graphique propre (aucun logo, illustration ou asset tiers).

### Palette « univers Volt » (jaune = action, rouge = alerte, noir = structure, blanc = lisibilité)
- `--accent` passe au **jaune Volt `#FFD23F`** (texte noir `#14120A` dessus) : boutons principaux, onglet actif, puces actives, liserés, icônes de section, bouton Signaler.
- **Rouge `#E3172F` réservé aux alertes** : SOS, Arrêter, dangers, marqueurs « danger », vitesse > 25 km/h. `--danger` et `--alert` unifiés.
- Logo : éclair jaune sur pastille noire (landing, écran d'accès, barre du bas, menu). Trottinette 3D et trajet 3D de l'accueil en jaune ; halo du marqueur 3D en bleu.
- Fond noir profond conservé pour le chrome ; mode clair toujours disponible.

### Carte « type GPS »
- **Style jour retouché** (`MapView.tuneDay`) : fond `#F5F6F8`, voirie grise franche et plus large (mineure `#CDD2DA`, majeure `#C3C9D3` avec liseré `#AEB5C1`), parcs `#CFEAC5`, eau `#BFDCF3`, bâtiments `#E4E7EC` (3D `#d9dde5`). Style nuit v0.10 conservé.
- Thème de carte **Auto = soleil** (claire le jour, sombre après le coucher du soleil à Strasbourg) ; « Jour », « Nuit », « Comme l'app » au choix. Le bouton 3D (bâtiments + caméra inclinée) et le relief 3D / survol 4D (mode avancé) restent dans le panneau Calques et sur les boutons de carte.

### Onboarding (nouveau)
- Après inscription (ou premier lancement d'un compte existant) : **Bienvenue sur Volt&Go — Le GPS pensé pour les trottinettes électriques** → **Quel véhicule utilisez-vous ?** (🛴 Trottinette électrique, 🚲 Vélo électrique, 🚴 Vélo, 🛵 Autre véhicule léger — mémorisé comme profil d'itinéraire, nouveau profil `bike`) → **Enregistrez votre domicile et votre travail** (Définir ouvre la recherche d'adresse) → écran de localisation → **carte**. Indicateur d'étapes, Ignorer à chaque étape, une seule fois (`onboarded`).
- **La carte est le premier écran** ; le tableau de bord reste accessible via le menu ☰ « Accueil ».

### Chrome façon GPS
- **Barre du bas** : Carte · Rechercher · **Signaler** (bouton jaune central, drapeau) · Recharge · Profil. Rechercher ouvre « Où va-t-on ? » ; Recharge ouvre la nouvelle liste des **points de recharge** (OSM, distance, prises, gratuit / payant, horaires, itinéraire) avec les ateliers dans les autres puces.
- **Menu latéral ☰** (bouton en haut à gauche, glissement depuis le bord) : carte utilisateur (initiale, forfait, modèle), 14 entrées — Accueil, Navigation, Carte et calques, Signalements autour de moi, Recharge, Réparateurs, Parkings vélo / trottinette (active le calque et zoome), Historique et mes trajets, Ma trottinette, Autonomie (nouvelle page), Communauté (nouvelle page : vos contributions, règles), Abonnement, Paramètres, Aide et bons réflexes.
- **Compteur de vitesse en direct** en bas à gauche : rond noir, chiffre en gros, anneau jaune qui se remplit jusqu'à 30 km/h, **rouge au-delà de 25 km/h** (limite légale), badge SIM en simulation. Vitesse issue du GPS du téléphone (`speed` en m/s, lissée), masquée tant qu'il n'y a pas de position.
- **SOS compact** : petit bouton rouge « SOS » au-dessus du compteur (mêmes actions : forces de l'ordre, panne, secours batterie, 17 / 18 / 112) ; « BATT » clignotant si batterie faible. La scène 3D du bouton est retirée.

### Navigation
- **Panneau de manœuvre** compact en haut à gauche : noir, grande flèche blanche, distance en gros, nom de rue en jaune ; carte « Puis … » en dessous.
- **Alertes en bandeau** juste au-dessus de la barre ETA (travaux, signalements, montée, batterie, arrivée), liseré jaune / rouge / bleu selon la gravité, animation d'entrée.
- **Barre ETA** : `3 min • 18:08 • 890 m` centrés, destination dessous, bouton **Recentrer** à gauche, voix, **Arrêter** rond rouge ; barre de progression et batterie estimée à l'arrivée. **Bouton Signaler jaune** flottant à droite pendant le guidage (signalement en un geste). Contrôles de carte masqués en navigation.

### Signalements façon GPS communautaire
- **Catalogue** (18 types) : 👮 Présence des forces de l'ordre, ⚠️ Danger, 🕳️ Nid-de-poule, 🚧 Travaux, 🐌 Ralentissement, 💥 Accident / incident, 🛣️ Route dégradée, 🔺 Ralentisseur, 🚲 Piste cyclable bloquée, 🚫 Route bloquée, ⛔ Route interdite, ↪️ Déviation, 👁️ Zone de vigilance, 🔌 Recharge disponible, 🔋 Problème de recharge, 🔧 Réparation, 🅿️ Parking vélo / trott., ℹ️ Autre. Durées de vie adaptées (1 h pour un ralentissement, 30 j pour un ralentisseur ou un parking). Aucun radar (R413-15).
- **Marqueurs ronds** avec pointe, bord coloré selon le ton (jaune / rouge / bleu / vert) ; **police = pastille bleue 👮** (dessin propre). Confirmations « Toujours présent / Plus présent », indice de confiance, expiration, masquage préfectoral inchangés.
- Le schéma Supabase (`report_types`) est complété avec les 8 nouveaux types.

### Itinéraires Rapide / Sûr / Confort
- Pour le véhicule choisi, trois styles : **🟢 Rapide** (le plus direct, routes partagées acceptées), **🔵 Sûr** (pistes, voies vertes, rues apaisées), **🟡 Confort** (évite revêtements dégradés et fortes pentes). Rapide et Sûr sont calculés en parallèle (2 appels Valhalla par recherche, au lieu de 1 + 2 alternatives), Confort **au toucher** (« Calculer »). Chaque ligne explique la différence, donne durée, distance, heure d'arrivée, dénivelé, signalements sur le trajet et **batterie à l'arrivée** ; « (identique) » quand Sûr = Rapide.
- CTA « Démarrer · Rapide / Sûr / Confort ».

### Fiche lieu
- En-tête nom + catégorie, badges (fiche vérifiée, ouvert / fermé, distance), **4 actions** Appeler · Enregistrer · **Partager** (Web Share, sinon copie) · Site web, adresse, services, marques, horaires, source ; grand bouton jaune **« Voir les itinéraires »** en pied.

### Corrections
- Champ `Net.health` séparé pour la qualité de l'air (`airq`) ; météo : nouvelle tentative 30 s après un échec.

### Tests
- 31/31 unitaires, **89 vérifications** de bout en bout (nouvelles : onboarding en 3 écrans, véhicule mémorisé, carte premier écran, barre du bas GPS, onglet Recharge, menu ☰ 14 entrées, SOS compact + compteur GPS, palette jaune, carte GPS jour/nuit selon le soleil, pastille police), 44 captures.

## v0.10.0-dev — 27/09/2026 — « Noir profond pro » : plus de blanc, texte lisible partout

Retour terrain (captures sur téléphone) : la barre du bas et les puces posées sur la carte claire étaient illisibles (verre blanc à 5 % + texte blanc sur fond de carte blanc), les marqueurs d'ateliers formaient un tas de carrés blancs de loin, et l'app basculait en clair selon le téléphone.

### Fond noir partout, pas de blanc
- **Apparence « Sombre » par défaut** (plus « Auto ») : l'app est noire quel que soit le réglage du téléphone. Auto / Soleil / Clair restent disponibles dans Réglages → Apparence pour ceux qui les veulent.
- **Carte en style nuit par défaut** : le thème de carte « Auto » suit désormais l'apparence de l'app (sombre → nuit) et non plus le soleil ; « Soleil » devient un choix explicite. Le style nuit est retouché pour un noir profond pro : fond `#0a0a0c`, voirie un peu plus lisible (`#232326` → `#2e2e34` selon la classe), eau bleu-noir, parcs vert-noir, bâtiments `#111114`. La mini-carte du Dashboard suit.
- **Fini le verre blanchâtre** : toutes les surfaces (cartes, tuiles, forfaits, fiches, formulaire, écran d'accès, lignes de trajet) passent en **noir profond translucide** `rgba(14,14,17,.86)` avec bord fin à 9 % et reflet à 7 %, au lieu du blanc à 5,5 % qui grisait tout sur les fonds clairs.
- **Éléments posés sur la carte** : barre du bas `rgba(8,8,10,.96)` (texte gris clair, actif rouge), panneau `rgba(8,8,10,.93)`, barre de recherche, boutons ronds (calques, 3D, SAT, position), puces de filtres `rgba(10,10,12,.92)` avec texte blanc — puce active rouge. Plus aucun texte blanc sur fond clair.
- **Marqueurs** : ateliers, recharges, gonflage en noir `#121215` avec bord coloré (rouge / vert / gris) ; partenaires en rouge plein. Attribution et contrôles MapLibre en sombre.
- **De loin** (zoom < 11,5) : seuls les signalements et les fiches vérifiées restent affichés ; les ateliers OSM, recharges et stations de gonflage se masquent (classe `map-far`), fini le tas de carrés à l'échelle régionale.

### Tests
- 3 vérifications remplacées / ajoutées : carte nuit par défaut avec fond retouché, barre du bas quasi opaque noire, marqueurs sans fond blanc, noir profond par défaut même avec un système en clair. Le mode clair explicite reste testé (contraste 17,9:1).

## v0.9.0-dev — 27/09/2026 — Toutes les sources ouvertes de la carte, en filtres, sans saturer

### Calques de données = filtres (demande : « ajoute tous les API que l'on peut ajouter, sans saturer, comme des filtres à un endroit logique »)
- **Endroit logique** : la rangée de filtres au-dessus de la carte garde ses 5 puces de base (Pistes, Signalements, Recharge, Ateliers, Gonflage) et gagne une puce **« Calques »** (en pointillé, compteur rouge des calques avancés actifs) qui ouvre le panneau **« Calques et carte »**, réécrit par groupes : Fond de carte (jour / nuit / auto, **satellite**, **bâtiments 3D**), Aménagements, Communauté, Services, Transports, Trafic & travaux, Météo. Chaque ligne indique ce qui s'affiche, à partir de quel zoom, sa source (`EMS · OSM`, `Open-Meteo`…) et un badge « temps réel » s'il y a lieu. Bouton « Réinitialiser ». Les calques avancés actifs apparaissent aussi dans la rangée pour être coupés d'un geste.
- **7 nouvelles sources** (12 calques au total) :
  - **Arceaux vélo** — 5 685 stationnements de l'Eurométropole, regroupés en clusters (somme des places) dès le zoom 13, détaillés dès le zoom 14, abrités en bleu foncé ; fiche avec conseil antivol.
  - **Fontaines à eau** — OpenStreetMap, ajoutées à la requête Overpass principale et à l'instantané embarqué (92 fontaines).
  - **Stations Vélhop** — 40 stations, vélos et places disponibles **en temps réel** (flux GBFS de l'Eurométropole, toutes les 2 min) : le plan B en cas de panne.
  - **Tram & bus** — 102 stations de tram (data.strasbourg.eu, cache 7 j) + arrêts de bus OpenStreetMap chargés **pour la vue courante** à partir du zoom 15 ; fiches avec règle CTS (trottinette pliée admise hors pointe).
  - **Trafic temps réel** — 468 tronçons SIRAC (grands axes), fluide / dense / saturé en vert / orange / rouge, état d'exploitation (fermé, travaux, déviation, neige), taux et vitesse, rafraîchi toutes les 3 min.
  - **Travaux & alertes** — emprises des chantiers voirie et ouvrages d'art programmés cette année (181 polygones orange) avec lien vers la carte 3D de l'Eurométropole, plus les alertes de circulation (points).
  - **Météo & qualité de l'air** — puce vivante dans la rangée de filtres (`☀️ 12° | 💨 8 NE | 🌧 40 % | Air bon`) ; fiche avec prévisions 6 h (temps, pluie, vent), indice européen de l'air (PM2,5, PM10, NO₂, O₃) et **conseils trottinette** : vent fort = autonomie en moins, pluie = freinage doublé et rails glissants, froid = batterie -15 à -30 %, brouillard = feux et gilet (R431-1-2), air dégradé = pistes en site propre.
- **Sans saturer** : rien n'est téléchargé tant qu'un calque est éteint (tout est éteint par défaut sauf pistes + signalements) ; couches denses rendues par MapLibre en clusters / cercles / lignes (aucun marqueur DOM), visibles seulement à un zoom lisible, libellés optionnels ; arrêts de bus par cellule de vue de 0,01° (12 cellules max, une seule nouvelle tentative 10 s après un échec Overpass) ; arceaux stockés en forme compacte (≈ 150 ko) 7 jours ; flux temps réel suspendus quand l'onglet est caché ou hors de l'écran carte, arrêtés à la désactivation ; un seul écouteur de clic par couche, curseur main au survol.
- **Fiches** au clic sur n'importe quel point ou tronçon : source et licence, horaires, bouton **Itinéraire**.

### Corrections
- **Couches sous la voirie en mode nuit** : le style `dark` d'OpenFreeMap place un libellé (`water_name`) avant les routes ; nos couches s'inséraient « avant le premier symbole » et passaient donc **sous les routes et les bâtiments** la nuit. `MapView.firstSymbolLayer()` choisit désormais le premier libellé placé après la dernière couche de voirie : pistes BNAC, itinéraires, trafic, tout est au-dessus des routes, sous les noms.
- Test bout en bout de la photo de modèle : la tolérance « Wikimedia limite cette IP (429) » ne se déclenchait jamais (`window.Net` inexistant) ; corrigé, 72/72 sur la v0.8 confirmé.
- Instantané OSM embarqué daté du 27/09/2026 (254 objets, dont 92 fontaines).

### Panneau DEV
- Deux lignes de plus : « Calques open data EMS » et « Météo + qualité de l'air », avec la santé réseau des points d'accès `ems` et `meteo`.

### Tests
- 31/31 unitaires, **80 vérifications** de bout en bout (13 nouvelles sur les calques : installation, invisibilité par défaut, panneau, chargement de chaque source avec comptages réels, puce et fiche météo, arrêts de bus par vue, réinitialisation, survie au changement de style), 41 captures.

### Légal
- Nouvelles licences documentées dans LEGAL-RGPD.md : Licence Ouverte (Eurométropole), ODbL (OSM), **CC BY 4.0 Open-Meteo — abonnement requis avant lancement commercial**.

## v0.8.0-dev — 27/09/2026 — Fond noir animé neutre, conteneurs verre iOS, rouge sur les conteneurs

### Fond
- Fini le fond rouge : le shader plein écran dessine un **noir profond animé et neutre** — nappes de graphite très sombres qui dérivent lentement (bruit de valeur), poussière fine qui scintille, vignette douce, légère réaction au pointeur et au défilement. Aucune couleur dans le fond. En clair : blanc avec nappes gris très pâle.

### Conteneurs « verre iOS » (glassmorphism)
- Cartes du Dashboard, tuiles, forfaits, fiches, choix de l'assistant, formulaire, carte d'accès, boutons ronds et carrés, barre de recherche, boutons de carte, onglets de jours : verre translucide (`rgba(255,255,255,.055)`, flou 22 px, saturation 180 %), bord fin `rgba(255,255,255,.13)`, reflet supérieur, ombre basse.
- Barre du bas, panneau sous la carte, modales, recherche plein écran : même verre, flou 28 px.
- **Rouge sur les conteneurs** : liseré rouge fin en haut de chaque carte, icônes et titres de section en rouge, pastilles d'icônes rouge translucide (tuiles, lignes, trajets, carnet), faisceau rouge conservé sur « Ma trottinette » et l'écran d'accès.
- Mode clair : verre blanc à 62 %, bords noirs à 8 %, mêmes accents rouges.

### Tests
- 31/31 unitaires, **72/72 bout en bout**, aucune erreur JavaScript, 37 captures.

## v0.7.0-dev — 27/09/2026 — WebGL et Three.js partout

### Fond WebGL « nébuleuse » (tout le site, sauf la carte)
- Un quad plein écran, un shader : **noir profond**, trois halos rouges qui respirent (l'un suit le pointeur avec inertie), poussière lumineuse qui dérive et scintille, vignette ; le défilement décale les halos. En mode clair : blanc cassé et halos rosés très doux. Rendu à 50 % de la résolution, 30 images/s, arrêté sur la carte et onglet caché, image fixe si « réduire les animations ». Rien de gris, rien de métallisé.
- Les cartes redeviennent légèrement translucides sur le sombre pour laisser passer les halos.

### Accueil (landing)
- **Scène « Strasbourg en 3D »** (Three.js) dans la section Eurométropole : la Grande Île entourée de l'Ill, la cathédrale, 260 immeubles qui **sortent du sol** à l'apparition, un trajet rouge qui se dessine avec son repère lumineux, caméra en orbite qui réagit au pointeur.
- Hero : **traînées de vitesse** rouges (additives), **poussière lumineuse** (500 points), parallaxe de caméra au pointeur.
- Cartes de fonctionnalités : **inclinaison 3D** (perspective) qui suit le pointeur, projecteur, apparition au défilement.

### Dashboard
- Trottinette 3D **à faire tourner au doigt** (glisser horizontalement) avec inertie, puis retour au balancement automatique.

### Tests
- 31/31 unitaires. **72/72 bout en bout** (nouveaux : fond WebGL actif, scène Strasbourg rendue), aucune erreur JavaScript, 37 captures.

## v0.6.0-dev — 27/09/2026 — Photo du modèle, écran d'accès premium, effets 21st.dev

### Photo de la trottinette (Dashboard)
- Dès que marque et modèle sont renseignés, l'app cherche une **photo libre du modèle** sur **Wikimedia Commons** (API publique, `origin=*`) : requêtes successives (indice pour les modèles courants, puis « marque modèle electric scooter », puis « marque modèle scooter »), titres filtrés (marque + tous les mots du modèle, exclusion des téléphones, montres, logos, batteries…), image la plus « vue d'ensemble » retenue. Auteur et licence affichés sous la photo, page source mémorisée. Résultat mis en cache 7 jours ; un échec réseau n'est pas mis en cache.
- **Ma photo** : bouton « Ajouter ma photo » (Dashboard et fiche) → caméra ou galerie, image réduite à 1 000 px et compressée en JPEG, stockée sur le téléphone uniquement ; « Retirer ma photo » dans la fiche. Une photo du client prime sur la photo Commons ; sans photo, la trottinette 3D reste affichée.
- Aucune photo constructeur copiée depuis un site officiel : ce serait une contrefaçon ; les photos Commons sont sous licence libre (CC0, CC BY, CC BY-SA), créditées.

### Écran d'accès (connexion / inscription)
- Halos « aurora » animés en fond (transformations GPU, pas de filtre de flou), carte en verre avec faisceau lumineux, ligne de confiance « 7 jours offerts · sans carte · sans pub », bouton retour rond.
- Inscription : **étapes numérotées** Identité → Sécurité → Véhicule (coche verte une fois validée), champs avec icône, œil pour afficher le mot de passe, jauge de solidité, transition glissée entre les écrans.
- Connexion : mêmes champs à icône, accroche « Votre trottinette vous attend ».
- Notice démo compacte.

### Effets sur tout le site (inspirés de 21st.dev, Magic UI, Aceternity ; sans dépendance)
- **Projecteur** (spotlight) sur les cartes du Dashboard et les forfaits : un seul écouteur de pointeur, écriture de variables CSS, jamais de re-rendu ; réservé au thème sombre et aux pointeurs fins, coupé si « réduire les animations ».
- **Faisceau de bordure** (border beam) : dégradé conique animé par `@property`, masqué dans une bordure de 1,5 px, sur la carte « Ma trottinette » et la carte d'accès ; désactivé si le navigateur ne le supporte pas.
- **Chiffres qui montent** (count-up) sur vitesse max, énergie, autonomie, consommation, batterie.
- **Anneau de vitesse** SVG autour du compteur (0 → 25 km/h, rouge au-delà).
- **Marquee** des fonctions sous l'accueil, **apparition au défilement** des sections, titre de l'accueil en dégradé animé, fondu entre écrans, **retour haptique** discret sur la barre du bas.

### Tests
- 31/31 unitaires. **71/71 bout en bout** (nouveaux : photo Commons affichée avec licence — « Photo : Axel.206 · CC0 » pour Xiaomi Mi Pro 2 —, écran d'accès aurora + étapes), aucune erreur JavaScript, 36 captures. Le test navigue avec un User-Agent Chrome Android : Wikimedia refuse (429) les navigateurs sans identité, comme le Chrome sans tête du test par défaut.

## v0.5.0-dev — 27/09/2026 — Noir profond, mode clair intelligent, barre du bas flottante, finitions

### Fond
- **Fin de l'effet métal gris** : le module `MetalBG` (shader WebGL) et son canvas sont supprimés. Le sombre est un **noir profond** `#000`, les cartes ressortent par un léger relief (`--card-bg`, liseré supérieur).

### Mode clair intelligent
- Réglages → **Apparence** : **Auto** (suit le réglage clair / sombre du téléphone, réagit en direct), **Soleil** (clair le jour, sombre à la nuit tombée, calcul solaire local, re-vérifié toutes les 5 minutes), **Clair**, **Sombre**.
- Toutes les couleurs de l'interface passent par des jetons : fonds, cartes, barre, creux, champs, bordures, textes, **et les textes sur fonds teintés** (badges OK / attention / danger / info / démo, pilule d'essai) qui deviennent foncés en clair. Le rouge de survol est assombri en clair pour rester lisible sur blanc.
- `color-scheme` et `meta theme-color` suivent le thème ; les scènes 3D adaptent sol et brouillard.
- Test automatique : texte noir sur fond clair avec un contraste mesuré de **17,9:1**, retour au blanc sur noir en sombre. Landing bureau testée avec une préférence système « clair ».

### Barre du bas
- **Flottante** à 10 px des bords, 68 px, coins 26 px, verre avec flou 24 px et liseré supérieur, ombre portée.
- Onglet actif : rouge sur fond rouge à 10 %, trait lumineux au-dessus, icône relevée avec halo.
- Bouton « + » de 58 px en relief : dégradé rouge, reflet, anneau qui pulse (désactivé si « réduire les animations »).
- Sur ordinateur, la barre reste une colonne à gauche.

### Trottinette 3D sur la carte
- Plus petite, comme demandé : ≈ 14 px en navigation, ≈ 22 px sur la carte (jamais moins de 2,6 m réels).

### Finitions sur tout le site
- Entrée en cascade des cartes et des tuiles (0,42 s, décalage par carte), désactivée avec « réduire les animations ».
- Boutons principaux : reflet qui balaie au survol, halo rouge ; boutons carrés et ronds : pression 0,93 ; champs : fond relevé au focus ; pastilles actives avec halo ; interrupteurs et segments actifs avec halo.
- Cartes, tuiles et forfaits : légère élévation au survol (pointeur seulement).
- Titres de section avec trait rouge ; gros chiffres en dégradé de texte ; ligne de trajet sélectionnée avec liseré rouge ; barre de recherche avec liseré ; scène d'accueil avec ombre rouge ; sélection de texte rouge ; barres de défilement fines.

### Tests
- Tests unitaires : 31/31 PASS. Parcours de bout en bout : **69/69 PASS** (nouveaux : fond noir sans canvas métal, mode clair avec mesure du contraste, retour au sombre, landing bureau en auto-clair), aucune erreur JavaScript, 36 captures.

## v0.4.0-dev — 27/09/2026 — Fin de la « connexion trottinette », calculateur d'autonomie, carnet d'entretien, panneau façon Uber

### Connexion à la trottinette retirée (c'était creux)
- Suppression de tout le module Bluetooth (Web Bluetooth, trames 55AA / 5AA5, fenêtre « Connecter », bouton Bluetooth du Dashboard, actions Verrouiller / Feu / Régulateur, cartes Température / Puissance / Erreurs, ligne Réglages, drapeaux `ble` du catalogue). Raison : aucun constructeur n'ouvre d'API, les protocoles communautaires ne marchent que sur de vieux firmwares, et sonner ou bloquer à distance est impossible. Rien de fiable n'aurait été livré au client.
- Les fonctions pures de trames restent dans `logic.js` (testées) mais ne sont plus utilisées par l'app.

### Fiche trottinette : les vraies caractéristiques
- La fiche insiste sur la **tension (V)** et la **capacité (Ah)** → énergie en Wh calculée en direct, l'autonomie annoncée et constatée, le niveau, le compteur.
- Nouveaux champs : **« Distance que je veux pouvoir parcourir »** (km) et **chargeur (A)**.

### Calculateur d'autonomie (carte « Autonomie » du Dashboard)
- Bornes en km du client : **km possibles maintenant**, **km sur batterie pleine**, **consommation Wh/km**.
- Champ « Km à parcourir » : verdict immédiat — OK avec le % de batterie utilisé et ce qu'il restera, ou Insuffisant avec les km manquants — plus les Wh nécessaires et le temps de recharge complète si le chargeur est renseigné. Réserve de 10 % conservée. `Logic.rangePlan`.

### Carnet d'entretien
- Nouvelle page (bouton clé à molette du Dashboard, carte « Carnet d'entretien », Réglages) : prochaines échéances avec bouton « Fait », ajout d'une intervention (type parmi 9, date, compteur, atelier avec suggestion des ateliers connus, coût, note), historique avec total, suppression, export texte.
- Une intervention d'un type suivi remet le rappel correspondant à zéro et met le compteur à jour.
- Le rapport de diagnostic reprend les 5 dernières interventions.

### Panneau sous la carte façon Uber
- Panneau **plus haut** : 44 % de l'écran au repos, 62 % ouvert, plein écran au-delà.
- Accueil carte : phrase d'accroche, **tuiles Domicile / Travail** (grandes), **tuiles Réparer / Recharger / Bus / Trajets**, carte batterie, récents, signalements autour de vous.
- Choix du trajet : en-tête centré « Choisissez un trajet » avec flèche de fermeture, lignes par option (icône du profil, nom + badge Recommandé, durée · distance · arrivée · D+, **% de batterie** en valeur à droite, vert / orange / rouge selon la marge), ligne sélectionnée surlignée, grand bouton collant **« Choisir Trottinette · Démarrer »**.

### Divers
- Dashboard : 9 cartes (ma trottinette, autonomie & calcul, compteur, actions rapides, batterie, carnet d'entretien, distance, historique, bons réflexes), bouton Carnet en haut.
- Forfait Plus : « Carnet d'entretien et rappels personnalisés » remplace la ligne Bluetooth. Landing et politique de confidentialité mises à jour.
- Service worker `voltgo-v0.4.0`.

### Tests
- Tests unitaires : 31/31 PASS. Parcours de bout en bout : **66/66 PASS** (nouveaux : calculateur 20 km avec 36 V × 12,8 Ah, absence de tout élément de connexion, carnet d'entretien avec remise à zéro du rappel freins), aucune erreur JavaScript, 33 captures.

## v0.3.0-dev — 27/09/2026 — Noir métal & rouge, 3D partout, urgence, assistant panne, abonnements

### Thème « Noir métal & rouge »
- Fin du jaune : accent **rouge flash légèrement sombre** `#E3172F` (survol `#FF3B4E`, profond `#9E0B1F`). Le danger passe à l'orange-rouge `#FF6B4A`, l'avertissement à l'orange `#FF8A3D`, et le **violet** `#B26BFF` remplace l'orange pour tout ce qui est simulé ou démo.
- **Fond métal brossé** animé sur tout le site et toute l'app (là où il y avait du noir) : shader WebGL brut (`fx.js`, `MetalBG`), brossage horizontal, balayage lumineux lent, reflet qui suit le doigt ou la souris, lueur rouge sourde, vignette. 30 images/s, rendu à 60 % de la résolution, pause hors écran, sur la carte et quand l'onglet est caché ; image fixe si « réduire les animations ».
- **Conteneurs affinés** : cartes translucides (le métal se voit à travers), bord fin de 1 px, rayon 18 px, padding 14–16 px, titres en 700 au lieu de 800–900, libellés plus petits, gros chiffres réduits (3,1 rem), tuiles et actions rapides plus compactes, boutons 44 px, champs 44 px, interrupteurs 48×28 px.
- Barre du bas plus fine (72 px), translucide avec flou, bouton + rouge dégradé.
- Fenêtres modales translucides avec flou, coins 22 px.

### Trottinette 3D (Three.js r160, scènes temps réel)
- Modèle de trottinette **procédural** (plateau arrondi, roues à pneu et jante, fourche inclinée, guidon, feux, accents rouges), matériaux métal noir brillant avec **reflets d'environnement** (carte PMREM générée à la volée, sans fichier HDR).
- **Accueil** : la trottinette roule sur une route métallique qui défile, roues en rotation, caméra en orbite lente, lumière rouge de contre-jour.
- **Dashboard** : la trottinette tourne lentement dans la carte « Ma trottinette » dès que la fiche est remplie.
- **Carte** : **marqueur 3D à votre position**, orienté selon le cap, taille quasi constante à l'écran (façon voiture Tesla), roues animées en navigation, disque rouge au sol ; au-dessous du zoom 12, retour au point classique.
- **Bouton d'urgence** en bas à gauche : cœur rouge facetté, cage filaire en rotation, onde qui pulse.
- Un seul chargement de Three.js (différé), scènes montées à la demande, arrêtées hors écran, rendu plafonné pour rester fluide.

### Vue satellite
- Bouton **SAT** (avec icône satellite) à droite de la carte : orthophotos **IGN / Géoplateforme** (Licence Ouverte, France). Les routes, pistes et libellés restent visibles ; les aplats (bâtiments, parcs, eau) s'effacent. Préférence mémorisée, restaurée au changement de thème.

### Urgence (remplace le bouton « Secours »)
- Fenêtre Urgence : **Signaler un contrôle de police**, **J'ai une panne !**, **Secours batterie**, et appels **17 Police · 18 Pompiers · 112 Urgences UE** (liens `tel:`), rappel du 15 et du 114 par SMS.
- **Contrôle de police** : nouveau type de signalement « contrôle » (1 h 30, prolongé par les confirmations), créé en un geste à la position exacte, visible par tous, avec une **voiture de police** animée (gyrophare) sur la carte.
- **Masquage préfectoral** (art. L130-11 / L130-12 / R130-12) : module `blackouts`. Un ordre = point, rayon (2 km ou 10 km), début, fin. Pendant sa validité, les contrôles situés dans le rayon ne sont plus rediffusés, côté client (`Logic.blackoutHides`) et côté serveur (`reports_in_bbox`). Les dangers (obstacles, travaux…) restent toujours visibles. En démo, un ordre se simule depuis le panneau DEV.

### Assistant panne (une question par écran)
- 1) Quel est le problème ? (batterie, pneu, freins, moteur/électronique, châssis, autre) · 2) La trottinette est à vous ? (sinon : marche à suivre pour une location en libre-service) · 3) Vous êtes pressé ?
- Résultats : ateliers de réparation autour de vous, classés par pertinence (`Logic.matchShops`) : partenaire express, fiche vérifiée, adéquation au type de panne, **ouvert maintenant** si pressé, distance.
- Deux priorités au choix : **Partenaires express** ou **Prix accessible**. Les tarifs ne sont affichés que s'ils ont été communiqués (`priceTier`) ; sinon « Tarif : à demander ». Aucun prix inventé.
- Boutons Itinéraire, Appeler, Détails ; renvoi vers Secours batterie si la panne est une batterie à plat.

### Inscription page par page
- 3 écrans, 2 questions maximum par écran : prénom + e-mail → mot de passe + confirmation (jauge de solidité) → type de véhicule + CGU. Barre de progression, bouton retour, focus automatique.
- Le compte démarre avec **7 jours d'essai** sans carte bancaire.

### Forfaits, essai, paiement Revolut
- Forfaits : **Essentiel 4,99 €**, **Plus 5,89 €**, **Express 9,49 €** par mois (TTC). Express = réparation express dans les centres partenaires (diagnostic prioritaire, créneau sous 48 h) et avantages à venir, présentés clairement.
- Cycle de **29 jours** (demandé). À la fin de l'essai ou de la période payée, **l'app se bloque** (écran Forfaits sans barre du bas) jusqu'au paiement, au même prix. Rappel d'échéance à 3 jours.
- Changement de forfait à tout moment (la nouvelle période démarre au paiement). Désinscription en 3 clics depuis Réglages ; frais de dossier d'un mois **configurables** (`cancelFeeMonths`), voir le point légal.
- **Revolut Merchant** (page de paiement hébergée) via le Worker : `POST /billing/order` crée la commande et renvoie `checkout_url` ; retour dans l'app par `#pay=return` ; `GET /billing/status` interroge Revolut ; `POST /billing/webhook` reçoit `ORDER_COMPLETED` avec vérification de la signature HMAC-SHA256 (`Revolut-Signature`, tolérance 5 min). Le Worker émet un **jeton signé** `vg1.<payload>.<HMAC>` contenant le forfait, la date de paiement, l'échéance et la commande : c'est ce jeton qui débloque le client et dit quel forfait il a pris.
- Sans Worker (`CONFIG.proxyBase` vide) : **paiement de démonstration** clairement marqué DÉMO, jeton local.
- Réglages → carte **Abonnement** (état, changer, se désinscrire, dernier paiement). Landing → section **Forfaits**. CGU : articles 8 (essai et abonnement), 9 (désinscription), 10 (réparation express).

### Base de données et Worker
- `supabase-schema.sql` : type `controle` ; table `blackouts` (lecture publique, écriture admin) ; filtre de masquage dans `reports_in_bbox` ; tables `subscriptions` et `payments` (lecture par le propriétaire, écriture uniquement par le Worker en `service_role`) ; tâche `pg_cron` d'expiration des abonnements. 89 instructions validées.
- `worker-proxy.js` : routes `/billing/*`, variables `REVOLUT_SECRET_KEY`, `REVOLUT_ENV`, `REVOLUT_WEBHOOK_SECRET`, `BILLING_SECRET`, binding KV `BILLING_KV`, écriture Supabase facultative.

### Divers
- Panneau DEV : 7 nouvelles lignes (fond métal et 3D, satellite, contrôles et masquage, assistant panne, abonnements, Revolut), boutons « Simuler un ordre préfectoral ici » et « Terminer mon essai ».
- Politique de confidentialité : paragraphes Abonnement et Contrôles de police.
- `[hidden]` forcé en `display:none` (les formulaires de connexion et d'inscription pouvaient s'afficher ensemble).
- Débordement horizontal de la page Réglages corrigé (sélecteur de profils).
- Service worker `voltgo-v0.3.0`.

### Tests
- Tests unitaires : **31/31 PASS** (3 nouveaux : masquage préfectoral, cycle d'abonnement, appariement des ateliers).
- Parcours de bout en bout : **64/64 PASS**, aucune erreur JavaScript, 33 captures.

## v0.2.0-dev — 27/09/2026 — Tableau de bord, trottinette connectée, mode avancé EDPM, relief 4D

### Design « Noir & ambre » (d'après les captures de référence)
- Nouvelle charte : fond `#000`, cartes `#151515`, accent ambre `#FBBF24`, police **Montserrat** (remplace Overpass), interrupteurs 58×34 px, boutons principaux ambre, fiche de virage ambre, icône et manifeste ambre sur fond noir.
- **Barre du bas plus haute** (84 px + zone sûre, rayon 28 px) avec 5 onglets : Dashboard, Carte, **+** central surélevé (60 px, ambre), Réparer, Réglages. Elle est globale (niveau `<body>`), masquée en navigation, et devient une barre latérale de 96 px sur bureau.
- Nouveaux composants : `.page`, `.page-head`, `.sq-btn`, `.round-back`, `.dcard`, `.lbl-up`, `.big-num`, `.stat-grid`, `.mini-tiles`, `.qa-row`, `.mini-map`, `.cust-item`, `.elev`, `.slider-row`, `.trip-map`, `.day-tabs`, `.batt-bar`, `.tip`, `select` stylé, suffixes d'unité.
- 16 nouvelles icônes SVG (grille, compteur, Bluetooth, édition, thermomètre, tendance, poignée, montagne, cadenas ouvert, phare, feuille, partage, ampoule, lecture, arrêt, régulateur).
- Landing : nouvelle section « Votre trottinette » avec maquette du tableau de bord.

### Accueil = Dashboard (avant la carte)
- Après connexion, l'utilisateur arrive sur le **Dashboard**. Le lien `#app` ouvre directement la carte, et la carte principale n'est créée qu'au premier affichage.
- **Mini-carte** MapLibre en haut, avec la position et le bouton « Ouvrir la carte ».
- 11 cartes :
  - Ma trottinette (état de la fiche, bouton Connecter) ;
  - Compteur de vitesse (tuiles ASSIST / FREIN / SÉCU) ;
  - Actions rapides : Itinéraire, Enregistrer, Signaler, Secours, Verrouiller, Feu, Régulateur, Réparer, Diagnostic ;
  - Batterie ;
  - Distance ;
  - Température ;
  - Puissance ;
  - Erreurs ;
  - Entretien ;
  - Historique ;
  - Bons réflexes.
- Mise à jour ciblée chaque seconde, sans tout redessiner.
- **Personnaliser** : réordonner les cartes (glisser par la poignée au doigt, ▲▼ au clavier ou à la souris) et les masquer ou afficher. La disposition est mémorisée.

### Ma trottinette (fiche complète, synchronisée avec la carte)
- Catalogue de 15 marques : Xiaomi, Segway-Ninebot, Dualtron, Kaabo, Vsett, Teverun, Nami, Inokim, Niu, Apollo, Pure, Okai, Unagi, Kukirin et Autre. Chaque modèle porte ses **capacités réelles** : protocole lisible ou non, compatibilité Apple Localiser.
- Champs :
  - identité ;
  - tension (V), capacité (Ah) et énergie calculée (Wh) ;
  - autonomies ;
  - vitesse bridée et vitesse de croisière ;
  - moteur (W) ;
  - mode éco / standard / sport ;
  - poids du véhicule et du conducteur, équipement ;
  - kilométrage ;
  - dates et kilométrage des derniers entretiens ;
  - assurance.
- Au-delà de 25 km/h saisis, une **alerte légale** cite R311-1. La vitesse de croisière est plafonnée à 25 km/h.
- **Synchronisation automatique** : la fiche alimente le Dashboard, l'autonomie, la vitesse du profil Trottinette et le calcul du % de batterie par itinéraire.
- **Entretien** : échéances par défaut (pression tous les 14 jours, freins tous les 500 km, serrage tous les 300 km, révision tous les 1 500 km ou 365 jours) et alertes.

### Connexion Bluetooth (EXPÉRIMENTAL)
- Web Bluetooth + Nordic UART. Protocoles communautaires Xiaomi `55AA` et Ninebot `5AA5`.
- Lecture de la vitesse, de la batterie (%), de la tension, du courant, de la puissance, de l'autonomie restante, du kilométrage et de la température du contrôleur.
- Commandes **à proximité** : verrouiller, déverrouiller, phare, régulateur.
- Firmware chiffré (MiAuth / Ninebot récent) : il est **détecté et non contourné**, et l'app renvoie vers l'app officielle.
- Fenêtre de connexion honnête : ce qui marche pour **votre** modèle, liens vers l'app officielle, note Apple Localiser, mention « impossible à distance ».
- **Rapport de diagnostic** copiable ou partageable (Web Share), sans numéro de série.
- **Non livré, parce que c'est impossible ou illégal** :
  - sonner ou bloquer à distance ;
  - mise à jour du firmware ;
  - lecture des marques sans protocole public (Dualtron et autres) ;
  - débridage.

### Mode avancé « type OsmAnd » et profil EDPM sur mesure
- Page dédiée dans les Réglages, accessible aussi depuis l'aperçu d'itinéraire.
- Réglages :
  - vitesse de croisière (≤ 25 km/h) ;
  - évitement des routes principales, des pentes et des revêtements dégradés (0–100 %) ;
  - type de vélo Valhalla ;
  - trajet le plus court ;
  - exagération du relief ;
  - ombrage ;
  - terrain 3D.
- Le profil **« EDPM perso »** s'ajoute aux 3 profils existants et se traduit en options Valhalla (`use_roads`, `use_hills`, `avoid_bad_surfaces`, `cycling_speed`, `shortest`).

### Dénivelé et relief « 4D »
- Valhalla `elevation_interval: 30` : altitudes réelles tous les 30 m.
- Lissage sur 5 points et hystérésis de 2 m : **D+ / D−** fiables, pentes min et max.
- **Tracé coloré selon la pente** (`line-gradient`) et badge ↗ / ↘ sur chaque option.
- Graphique d'élévation SVG interactif, lié à un curseur sur la carte.
- **Relief 3D** (`raster-dem`, AWS Terrain Tiles) et **ombrage** (`hillshade`).
- **Survol 4D** : la caméra suit le trajet dans le temps (inclinaison 64°, zoom 16,2).
- **% de batterie utilisé** par option : Wh/km de base, facteur de mode et énergie des montées (m·g·h / 0,65), avec le reste estimé.
- **Export GPX** (avec altitudes) et **ouverture dans OsmAnd**.
- En navigation : **alerte avant les montées** (≥ 5 % sur ≥ 60 m).

### Historique des trajets
- Option « Enregistrer mes trajets », **désactivée par défaut**.
- Tracé simplifié (≤ 400 points), vitesse max, batterie au départ et à l'arrivée, 60 trajets.
- Onglets par jour, carte du tracé, statistiques, export GPX, suppression.
- Enregistrement libre (bouton Enregistrer) en plus des trajets guidés.

### Bons réflexes
- Paramétrer la destination avant de partir, activer le mode Conduite (Ne pas déranger), baisser la luminosité, fixer le téléphone sur un support, vérifier l'autonomie avant un long trajet (6 fiches).
- **Correction légale** : les écouteurs, **y compris à conduction osseuse**, sont interdits en roulant (R412-6-1, 135 €). La consigne du cahier des charges a été corrigée ; le guidage vocal passe par le haut-parleur du téléphone.

### Réglages (remplace l'onglet Profil)
- Cartes :
  - profil ;
  - Ma trottinette (fiche, connexion, batterie, diagnostic) ;
  - Tableau de bord (personnaliser, historique, bons réflexes) ;
  - Navigation (mode avancé, profil par défaut, voix, 3D, enregistrement des trajets) ;
  - notifications ;
  - confidentialité ;
  - sécurité ;
  - déconnexion.

### Robustesse
- `Net.json` refait une tentative automatique après une erreur réseau.
- Miroir Overpass `maps.mail.ru` ajouté, et **instantané OSM embarqué** (26/09/2026, 162 éléments) utilisé en dernier recours.
- Panneau DEV : lignes Bluetooth, dénivelé, relief, historique, avec l'état **BLOCKED** quand une fonction dépend du matériel ou d'un constructeur.
- Mentions légales mises à jour : historique avec tracé, données de la trottinette, article 4 bis sur le débridage.
- Service worker `voltgo-v0.2.0`, `start_url` `./#dash`.

### Base de données (`supabase-schema.sql`)
- Nouvelle table `vehicles`, avec RLS propriétaire et vitesse contrainte à 25 km/h au plus.
- Colonnes ajoutées à `trips` : `max_kmh`, `battery_start`, `battery_end` et `track` (optionnelle, sur consentement).
- Purge automatique des tracés après 1 an (`pg_cron`).
- 77 instructions validées par l'analyseur PostgreSQL.

### Tests
- Tests unitaires : **28/28 PASS**. 10 nouveaux tests portent sur les trames Bluetooth de référence, le dénivelé (bruit réel filtré), l'énergie, l'entretien et le GPX.
- Parcours de bout en bout : **46/46 PASS**, sans aucune erreur JavaScript.
- 25 nouvelles captures.

### Corrections pendant la phase de test
- Débordement horizontal des pages : `minmax(0,1fr)` et `min-width:0`.
- L'attribution de la mini-carte recouvrait son bouton.
- Les 4 profils passaient à la ligne : le sélecteur de profils défile désormais horizontalement.
- Le bruit d'altitude donnait 22 m de D+ sur 1 km plat : lissage et hystérésis ajoutés.
- La grille de la barre latérale sur bureau était écrasée par une règle plus tardive.
- Le bouton DEV chevauchait le panneau en plein écran : il est masqué dans ce cas.

## v0.1.0-dev — 26/09/2026 — Phase 0 + Phase 1 (premier prototype complet)

### Phase 0 — Architecture et audit
- Fusion des deux cahiers des charges (ChatGPT « master prompt » + Gemini) et arbitrage des contradictions : interface sombre en verre sur carte claire le jour / sombre la nuit ; sources modulaires assemblées en fichier unique ; Supabase à la place d'un serveur Node dédié ; Valhalla à la place de l'OSRM public.
- **Correction légale** : suppression du type « radar » (article R413-15 V du Code de la route), remplacé par « Zone de vigilance ». Type « contrôle » non activé tant que le module de masquage L130-11 n'existe pas.
- Vérification des sources : l'API Adresse `api-adresse.data.gouv.fr` a fermé en janvier 2026, remplacée par la Géoplateforme IGN ; CORS vérifié sur chaque service ; URL Strass&Go vérifiée (HTTP 200).

### Application (`index.html`, 375 Ko, fichier unique)
**Landing**
- Page SaaS en 8 sections : hero, pourquoi, navigation, recharge, réparation, communauté (cycle de vie d'un signalement), Strasbourg (chiffres réels de l'open data), appel final. Pied de page avec mentions, CGU, confidentialité, sources.
- Scène Three.js (r160, chargée à la demande) : la Grande Île entourée de l'Ill, la flèche de la cathédrale, un trajet qui se dessine, un signalement travaux. Pause hors écran, image fixe si « réduire les animations », visuel SVG de secours sans WebGL.

**Compte**
- Connexion, inscription (prénom, e-mail, mot de passe, confirmation, CGU), mot de passe oublié, session 30 jours, déconnexion, changement de mot de passe, suppression de compte, export JSON.
- Mode démo clairement affiché : PBKDF2-SHA256 150 000 itérations, blocage 60 s après 5 échecs. Adaptateur Supabase Auth prêt (validation e-mail, réinitialisation).

**GPS**
- Écran d'explication avant la demande ; gestion accordé / refusé / indisponible / délai / non pris en charge / contexte non sécurisé ; badge de précision (précis, ±m, imprécis) ; alerte signal perdu après 20 s ; arrêt depuis le profil.
- Simulation de position (DÉMO) le long d'un trajet ou à la main, toujours signalée : bandeau orange, marqueur orange, libellé « Position simulée ».
- Mode économie si le téléphone passe sous 15 % : GPS moins fréquent, 3D coupée.

**Carte**
- MapLibre GL 5.6.0 + OpenFreeMap (Positron le jour, Dark la nuit), bascule automatique au coucher du soleil calculé pour Strasbourg, choix manuel possible.
- Aménagements cyclables : pistes OSM à toutes les échelles + open data BNAC de l'Eurométropole chargé par cellules (5 styles : piste, voie verte, bande, mixte, double sens).
- Bâtiments 3D (fill-extrusion), bouton 2D/3D, suivi de position (libre / suivre / suivre le cap), calques et légende, attribution conforme.

**Recherche**
- Géoplateforme (adresses) + Photon (lieux) + fiches locales en parallèle, annulation des requêtes obsolètes, résultats proches (< 60 km) en premier, distance affichée, domicile, travail, favoris, récents, choix sur la carte, recherche inversée d'adresse.

**Itinéraires et navigation**
- Valhalla : profils Trottinette, Vélo élec., Prudent ; jusqu'à 3 alternatives ; heure d'arrivée ; batterie suffisante / juste / insuffisante par option ; signalements présents sur le trajet ; erreurs traduites.
- Navigation : flèche et distance de la prochaine manœuvre, rue, manœuvre suivante si proche, heure d'arrivée, temps et distance restants, progression, tracé parcouru grisé, voix en français (annonce à ~200 m puis au virage), alertes signalements à 300 m, recalcul après 3 positions hors trajet (> 35 m, 1 recalcul / 12 s max), arrivée, écran maintenu allumé, estimation de batterie en cours de route.

**Signalements**
- 9 types, création en 2 gestes en navigation, précision facultative (140 caractères), placement sur la carte sans GPS.
- Confiance : statuts Nouveau / Actif / Confirmé / Contesté / Expiré / En vérification / Retiré, indice 0–100 %, votes « Toujours présent » / « Plus présent » qui ajustent la durée de vie, un vote par personne, pas de vote sur son propre signalement.
- Anti-spam : 45 s entre deux, 8 par heure, fusion des doublons à moins de 50 m. Alerte d'abus (masqué à 3), retrait par l'auteur ou un modérateur, journal de modération, purge 7 jours après expiration.
- 4 exemples de démonstration marqués « EX » et supprimables. Temps réel entre onglets en démo (BroadcastChannel).

**Énergie**
- « Ma batterie » : type, modèle, autonomie constructeur et réelle, pourcentage ; estimation prudente (70 % du constructeur sans autonomie réelle) ; rappel « estimation, pas une mesure ».
- « Secours » : recharge à portée (OSM) → bus avec Strass&Go (+ arrêts de tram/bus les plus proches) → atelier le plus proche. Bouton rouge pulsant si batterie ≤ 15 % ou < 3 km.

**Réparer**
- 6 fiches vérifiées (Strass Ride, L'Atelier de la Trott, Mobygum store, Urbain Mobility « à vérifier », Repair and Run, FastRide « hors zone ») + ateliers OSM ; filtres ; liste et carte synchronisées ; ordre vérifié → OSM → à vérifier.
- Fiche : appeler, itinéraire, site, enregistrer, adresse et numéro copiables, services, marques, horaires avec le jour en cours, ouvert/fermé seulement si fiable, source et date, « Information non disponible » pour tout champ absent, « Signaler une erreur ».

**Profil** : véhicule, profil par défaut, voix, 3D, animations, notifications, localisation, historique opt-in sans trace GPS, export, suppression, mot de passe, mentions, sources.

**Robustesse** : délais d'attente, nouvelle tentative réseau, bandeau hors connexion, message « service lent », bascule entre 3 instances Overpass, cache 24 h, instantané OSM daté embarqué, stockage local protégé (navigation privée), panneau DEV (état des API, PASS / DÉMO / REQUIRES API, modération, journal).

### Backend et infrastructure
- `supabase-schema.sql` : PostGIS, 12 tables, RLS partout, 5 fonctions RPC (lecture par zone, création avec anti-spam et doublons, vote, alerte, retrait) + 3 fonctions internes (statut, rôle, création de profil), temps réel, 3 tâches `pg_cron`, profil créé à l'inscription. Syntaxe validée par l'analyseur PostgreSQL (68 instructions).
- `worker-proxy.js` : Cloudflare Worker (routes, cache, bascule Overpass, CORS restreint, limite par IP, X-Client-Id).
- PWA : `manifest.webmanifest`, `sw.js` (réseau d'abord pour l'app, cache pour bibliothèques et tuiles, jamais pour les API), `icon.svg`.

### Tests
- 18 tests unitaires (logique métier) : 18/18 PASS.
- 28 vérifications de bout en bout sur Chromium (mobile 390×844, bureau 1440×900) avec les vrais services : 28/28 PASS. Détail dans `TESTS.md`.

### Corrections pendant la phase de test
- Calcul du coucher du soleil (formule de transit) corrigé.
- Classement de la recherche : « Gare Centrale » renvoyait Toulon ; les résultats proches passent désormais devant.
- Recadrage de la carte bloqué par le padding persistant de MapLibre : remis à zéro avant chaque recadrage.
- Itinéraire non recadré pendant un changement de thème de carte : corrigé.
- Bandeau SIMULATION qui masquait la distance du virage : le guidage descend sous le bandeau.
- Barre de recherche invisible sur bureau (sous le panneau) : corrigé.
- Pastille de filtre active illisible, contrôles qui chevauchaient l'attribution, bouton DEV qui masquait des éléments, durée d'itinéraire coupée sur deux lignes, prises « ×yes » : corrigés.
- Overpass saturé : bascule sur 3 instances + instantané embarqué.
