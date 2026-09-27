# Design system — v1.0 « Volt Navigator » : jaune / rouge / noir / blanc, chrome façon GPS

La v0.5 a retiré le fond métal gris de la v0.3 ; la v0.8 pose un **fond noir animé et neutre** (nappes de graphite, poussière, aucune couleur) et des **conteneurs en verre iOS** (flou, bord fin, reflet) portant les **accents rouges** (liseré haut, icônes, titres de section). La scène **Strasbourg en 3D** reste sur l'accueil. Un **mode clair** complet existe. Le principe : **aucune couleur de texte n'est écrite en dur**, tout passe par des jetons qui basculent avec `data-theme` sur `<html>`. Le texte est noir sur clair, blanc sur sombre, et les textes posés sur des fonds teintés (badges, notices) ont leur propre paire de jetons (`--c-ok`, `--c-warn`, `--c-danger`, `--c-info`, `--c-demo`, `--c-accent`). Contraste texte / fond mesuré : 17,9:1 en clair.

Modes (Réglages → Apparence) : **Auto** (suit `prefers-color-scheme` du téléphone), **Soleil** (clair le jour, sombre à la nuit tombée, calcul solaire local), **Clair**, **Sombre**. La carte garde sa propre logique jour / nuit.

Références appliquées :
- **Captures de référence de l'utilisateur** (structure Dashboard / Personnaliser / Historique, panneau Uber).
- **ui-ux-pro-max** : *EV / Charging*, *Running & Cycling GPS*, *Ride Hailing*, *Directory*, *SaaS pricing*.
- **Magic UI / Aceternity / Shadcn** : barre flottante en verre, indicateur actif lumineux, reflet qui balaie les boutons principaux, cartes à liseré supérieur, entrées en cascade ; réécrits en CSS pur.
- **Web Interface Guidelines** (Vercel) : audit en fin de document.
- **Mobbin** : connecteur payant, non utilisé.

## Couleurs (jetons)

| Jeton | Sombre | Clair | Rôle |
|---|---|---|---|
| `--ink-0` | `#000000` | `#F4F4F6` | Fond de l'application |
| `--ink-1` / `--ink-2` / `--ink-3` | `#0D0D0D` / `#151515` / `#1E1E1E` | `#FFFFFF` / `#FFFFFF` / `#ECECF0` | Surfaces, champs |
| `--card-bg` | `#161616 → #0F0F0F` | `#FFFFFF → #FAFAFB` | Cartes |
| `--bar-bg` | `rgba(8,8,9,.92)` | `rgba(255,255,255,.93)` | Barre du bas, panneau, recherche, boutons de carte |
| `--well` / `--input-bg` | `rgba(0,0,0,.4)` / `.45` | `rgba(0,0,0,.045)` / `#FFFFFF` | Creux (tuiles, calculateur), champs |
| `--line` / `--line-strong` | blanc à 8 % / 15 % | noir à 9 % / 16 % | Bordures |
| `--text` / `--text-2` / `--text-3` | `#FAFAFA` / `#A3A3A3` / `#6E6E6E` | `#0B0B0D` / `#4A4A52` / `#7A7A84` | Texte |
| `--accent` / `--accent-hi` / `--accent-deep` | `#E3172F` / `#FF3B4E` / `#9E0B1F` | `#E3172F` / `#C8102A` / `#9E0B1F` | Rouge de marque (le survol est assombri en clair pour rester lisible sur blanc) |
| `--c-ok` / `--c-warn` / `--c-danger` / `--c-info` / `--c-demo` | pastels clairs | `#15803D` / `#9A3412` / `#B91C1C` / `#1D4ED8` / `#6D28D9` | Textes sur fonds teintés |
| `--route` / `--charge` / `--warn` / `--danger` / `--demo` | `#3F86FF` / `#22C55E` / `#FF8A3D` / `#FF6B4A` / `#B26BFF` | identiques | Rôles fonctionnels |

Le violet « démo » est réservé : position simulée, comptes démo, exemples de signalements, paiement simulé, bouton DEV.

Pente du tracé (`slopeColor`) : descente (≤ −3 %) en vert, plat (< 2 %) en bleu, 2–5 % en rouge clair, 5–8 % en orange, 8 % et plus en rouge.

## Typographie

- **Montserrat** (400 → 900) pour toute l'interface. Titres en **700** (plus de 800–900 « pâte de mouche »), libellés de cartes en capitales espacées 10–11 px (`.lbl-up`), texte courant 400–500.
- Chiffres en `tabular-nums` (vitesse, %, km, heures) pour qu'ils ne « sautent » pas pendant le guidage.
- Échelle : 12 / 13 / 15 / 17 / 22 / 28 / 40 px ; grands compteurs (`.big-num`) à 3,1 rem (≈ 50 px).

## Espacements, rayons, ombres

- Base 4 px : 4, 8, 12, 16, 20, 24, 32, 40, 48.
- Rayons : 9 (segments), 12 (boutons, champs), 13–14 (petits boutons carrés), 18 (cartes), 22 (modales), pilule. La barre du bas a un rayon supérieur de 22 px.
- Ombres : `--sh-float` pour les éléments flottants, `--sh-sheet` pour le panneau inférieur.

## Composants

| Composant | Détail |
|---|---|
| **Barre du bas** (`.tabbar`) | **Flottante** (10 px des bords, 68 px, rayon 26 px), verre avec flou 24 px, liseré supérieur, onglet actif en rouge sur fond rouge à 10 % avec trait lumineux au-dessus, icône relevée avec halo, bouton « + » de 58 px en relief (dégradé rouge, anneau qui pulse). Devient une barre latérale de 96 px sur bureau. Masquée en navigation et sur l'écran Forfaits bloquant. |
| **Bouton Urgence** (`.sos`) | Rond de 58 px en bas à gauche de la carte, scène Three.js (cœur facetté, cage filaire, onde), libellé « URGENCE » ; pulse si la batterie est faible |
| **Bouton SAT** (`.fab.sat-btn`) | Contrôle de carte avec icône satellite et étiquette SAT ; rouge quand actif |
| **Assistant** (`.wiz`, `.choice-grid`, `.choice`) | Barre de progression en 3 segments, une question, 2 à 6 choix en grille, choix large (`.wide`) |
| **Forfaits** (`.plans`, `.plan`) | Carte par forfait avec étiquette (Populaire, Réparation express), prix en rouge, liste à coches, forfait courant surligné ; `.trial-pill` pour l'état de l'essai ; `.pay-summary` pour le récapitulatif de paiement ; `.rev-logo` |
| **Écran d'accès** (`.aurora`, `.auth-card.beam`, `.auth-steps`, `.in-ico`, `.trust-row`) | Halos animés, carte en verre avec faisceau, étapes numérotées (active rouge, faites vertes), champs à icône avec œil, ligne de confiance |
| **Projecteur** (`.spot`) | `radial-gradient` 260 px suivant `--mx/--my` écrits par un seul écouteur ; sombre + pointeur fin seulement |
| **Faisceau** (`.beam`) | `conic-gradient(from var(--beam))` animé via `@property`, masque XOR sur 1,5 px |
| **Compteur** (`.speed-gauge`, `#speed-ring`) | Anneau SVG 44 px de rayon, `stroke-dashoffset` animé |
| **Photo** (`.scooter-photo`) | 190 px, dégradé bas, légende licence |
| **Fond noir animé** (`#fx-bg`, `Nebula`) | Shader plein écran, bruit de valeur (nappes de graphite) + poussière, pointeur et défilement en uniformes, 30 i/s |
| **Verre iOS** (`--glass-bg`, `--glass-bd`, `--glass-hi`, `--glass-blur`) | Appliqué à toutes les surfaces ; liseré rouge `::before` sur les cartes ; pastilles d'icônes rouge translucide |
| **Scène Strasbourg** (`.city-stage`, `CityScene`) | 260–440 px de haut, Three.js, immeubles animés, trajet dessiné, parallaxe |
| **Inclinaison** (`.tilt`) | `perspective(900px) rotateX/rotateY` via `--rx/--ry`, même écouteur que le projecteur |
| **Marquee** (`.marquee`) | Piste dupliquée, 32 s, masque latéral |
| **Marqueur police** (`.mk-report.t-police`) | Voiture bleue avec gyrophare animé (CSS) |
| **Page** (`.page`, `.page-head`) | Titre fort, bouton carré (`.sq-btn`) à droite, retour rond (`.round-back`) sur les sous-pages |
| **Carte de tableau de bord** (`.dcard`) | Fond `--card-bg`, liseré supérieur, bord 1 px, rayon 18 px, padding 14–16 px, libellé en capitales 11 px avec icône rouge, valeur en 1,15 rem (`.val`), grille de statistiques (`.stat-grid`), mini-tuiles 50 px (`.mini-tiles`) |
| **Scène 3D du Dashboard** (`.scooter-illu`) | 150 px de haut, trottinette tournante, fond transparent |
| Actions rapides (`.qa-row`, `.qa`) | Itinéraire, Enregistrer, Signaler, Urgence, Carnet, Réparer, Diagnostic. Défilement horizontal. |
| **Panneau façon Uber** (`.svc-grid`, `.svc`, `.svc-big`, `.ride-row`, `.ride-cta`) | Tuiles de services (2 grandes + 4 petites, icône dans un carré rouge translucide), lignes de trajet (icône, nom, durée · distance · arrivée, valeur à droite = % de batterie), bouton pleine largeur collant « Choisir · Démarrer ». Panneau au repos à 44 % de l'écran, ouvert à 62 %. |
| Calculateur (`.range-calc`, `.calc-out`) | Champ « Km à parcourir » et verdict en badge (OK / Insuffisant) |
| Mini-carte (`.mini-map`) | MapLibre non interactive en haut du Dashboard, bouton « Ouvrir la carte » |
| Personnaliser (`.cust-item`) | Poignée de déplacement (glisser au doigt), flèches ▲▼ au clavier et à la souris (masquées sur écran tactile), interrupteur de visibilité |
| Profil d'élévation (`.elev`) | Graphique SVG, curseur lié à la carte, D+ / D− / pente max |
| Curseurs (`.slider-row`) | Réglages du mode avancé avec valeur affichée |
| Historique (`.day-tabs`, `.trip-map`) | Onglets par jour, carte du tracé, statistiques |
| Barre de batterie (`.batt-bar`) | Remplissage couleur selon le niveau |
| Bons réflexes (`.tip`) | Icône, titre, texte ; avertissement légal en rouge |
| Boutons | `primary` (dégradé rouge, reflet supérieur, texte blanc), `ghost`, `danger`, `charge`, `demo` (violet) ; hauteur 44 px (34 en petit), poids 600 ; retour tactile `scale(.97)` |
| Champs et `select` | 44 px, fond sombre translucide, focus rouge et halo, suffixe d'unité (`.suffix` : V, Ah, km/h), `aria-invalid` en rouge |
| Segmented control | Profils de trajet (défilable horizontalement), type de véhicule, mode, thème de carte |
| Interrupteurs | 48×28 px, piste rouge quand activé, vraie case à cocher accessible |
| Panneau inférieur | 3 hauteurs (aperçu, moitié, plein) ; barre latérale fixe sur bureau (≥ 960 px) |
| Fiche de virage | Carré rouge dégradé de 54 px avec flèche, distance en 1,7 rem, nom de rue |
| Modales | `<dialog>` natif ; feuille du bas sur mobile ; fermeture par Échap, par le fond ou par le bouton |
| Marqueurs | Signalement, atelier (vert si vérifié), recharge, gonflage, destination, position (orange si simulée) |
| Toasts | `aria-live="polite"`, 4 s |
| Bandeau système | Simulation, sinon hors ligne, sinon économie d'énergie (un seul à la fois, par priorité) |

### Calques et filtres (v0.9)
- **Rangée de filtres** : 5 puces de base toujours présentes, puis les calques avancés actifs (pour les éteindre d'un geste), puis la puce `Calques` en pointillé avec un compteur rouge des calques avancés actifs. La puce **Météo** est vivante : `☀️ 12° | 💨 8 NE | 🌧 40 % | Air bon` (pastille de couleur selon l'indice européen).
- **Panneau « Calques et carte »** : groupes (Fond de carte, Aménagements, Communauté, Services, Transports, Trafic & travaux, Météo), une ligne par calque = émoji, libellé, badge `temps réel` s'il y a lieu, sous-titre qui dit *ce qui s'affiche et à partir de quel zoom*, source en capitales mono (`EMS · OSM`, `Open-Meteo`), interrupteur ; sous-titre de la modale = nombre de calques actifs ; pied : `Réinitialiser` / `Terminé`.
- **Couleurs des couches** : tram rouge CTS `#E3001B`, bus anneau bleu ciel `#0EA5E9`, arceaux bleu `#3F86FF` (abrités `#1d4ed8`), Vélhop violet `#8B5CF6` (gris si aucun vélo), fontaines cyan `#06B6D4`, trafic vert `#22C55E` / orange `#F59E0B` / rouge `#EF4444`, travaux orange à 18 % avec tiret. Toujours un halo blanc (jour) ou nuit `#0b1220` pour rester lisible sur les deux styles.

### Noir profond pro (v0.10)
- Jetons sombres : `--glass-bg: rgba(14,14,17,.86)`, `--glass-bd: rgba(255,255,255,.09)`, `--glass-hi: rgba(255,255,255,.07)`, `--bar-bg: rgba(8,8,10,.96)`, `--well` et `--input-bg` blanc à 4–5 %. Règle : **jamais de surface blanche translucide sur le sombre**, jamais de texte blanc sur un fond clair.
- Sur la carte : barre du bas, panneau, recherche, boutons ronds et puces sont noirs quasi opaques (≥ 92 %) — la lisibilité ne dépend plus de ce qu'il y a derrière. Carte en style nuit retouché (`MapView.tuneNight`).
- Marqueurs : fond `#121215`, bord coloré par rôle (accent = atelier, vert = recharge, gris = gonflage), partenaire rouge plein. Masqués sous le zoom 11,5 sauf fiches vérifiées et signalements.
- Apparence par défaut : `uiTheme = 'dark'` ; le clair reste un choix explicite (`light`) ou automatique (`auto`, `sun`).

### Palette v1.0 et chrome GPS
- **Jaune Volt `#FFD23F`** (`--accent`, texte `#14120A`) = toute action : boutons, onglet actif, puces actives, bouton Signaler, liserés, icônes de section, anneau du compteur. **Rouge `#E3172F`** (`--alert`, `--danger`) = alertes uniquement : SOS, Arrêter, dangers, vitesse hors limite. **Noir / anthracite** = structure (barres, panneaux, cartes). **Blanc** = texte et pastilles de signalement.
- Carte jour « type GPS » : fond `#F5F6F8`, voirie `#CDD2DA` / `#C3C9D3` (liseré `#AEB5C1`), parcs `#CFEAC5`, eau `#BFDCF3`. Nuit : v0.10.
- Composants : `.top-row` (☰ + recherche), `.hud-left` (SOS compact `.sos-mini` + `.speedo`), `.drawer` (menu latéral, 320 px, glissement), `.tabbar` 5 entrées avec `.report-tab` central, `.turn-card` (noir, flèche blanche, rue jaune), `.nav-alerts` (bandeaux à liseré), `.nav-bottom` (ETA centrée, recentrer, voix, stop rouge), `.nav-report` (drapeau jaune flottant), `.mk-report` (pastille ronde 40 px + pointe, `.t-police` bleue `#2F80ED`), `.ob-*` (onboarding), `.ride-row` avec `.ride-why`.

## Règles UX appliquées

- **1 à 3 gestes** : signaler en navigation = 2 taps (drapeau, type) ; itinéraire = recherche + résultat + Démarrer.
- **Expliquer avant de demander** : écran dédié avant la fenêtre de géolocalisation du navigateur (un refus est quasi définitif sur iOS).
- **Dévoilement progressif** : l'accueil montre batterie, destinations, « autour de vous » ; le détail vient au glisser.
- **Réduction de l'anxiété** : « Votre trajet est prêt », « Vous êtes presque arrivé », autonomie toujours accompagnée de « estimation ».
- **Aucune donnée inventée** : « Information non disponible » plutôt qu'un champ deviné ; ouvert/fermé seulement si les horaires sont interprétables.
- **États vides et d'erreur rédigés** pour chaque écran (hors ligne, lent, sans GPS, sans itinéraire, données anciennes).

## Audit Web Interface Guidelines (Vercel)

| Règle | État |
|---|---|
| Boutons icônes avec `aria-label` | Fait |
| Libellés de formulaires, `autocomplete`, `type` et `inputmode` corrects | Fait |
| `spellcheck="false"` sur les e-mails | Fait |
| Focus visible (`:focus-visible`) | Fait |
| `prefers-reduced-motion` + préférence « Réduire les animations » | Fait |
| Pas de `transition: all` | Fait |
| `aria-live` sur toasts et guidage | Fait |
| Lien d'évitement (skip link) | Fait |
| `touch-action: manipulation`, `overscroll-behavior: contain` sur les panneaux | Fait |
| Zones sûres (`env(safe-area-inset-*)`) | Fait |
| `color-scheme: dark`, `theme-color` | Fait |
| `tabular-nums` sur les chiffres | Fait |
| Actions destructives confirmées | Fait (arrêt de navigation, suppression, déconnexion, retrait) |
| Dates via `Intl.DateTimeFormat` | Fait |
| `translate="no"` sur la marque | Fait |
| Zoom utilisateur non bloqué | Fait |
| Listes > 50 éléments virtualisées | À faire (liste des ateliers : 58 éléments) |
| Cibles tactiles ≥ 44 px (barre du bas, actions rapides, interrupteurs) | Fait (v0.2) |
| Glisser-déposer doublé d'une alternative clavier (Personnaliser ▲▼) | Fait (v0.2) |
| Pas de débordement horizontal (`minmax(0,1fr)`, `min-width:0`, `overflow-x:hidden` sur les pages) | Fait (v0.2, renforcé v0.3) |
| Animations WebGL en pause hors écran et onglet caché | Fait (v0.3) |
| `prefers-reduced-motion` respecté par les scènes 3D et les animations d'entrée | Fait (v0.3, v0.5) |
| Mode clair complet, texte noir / blanc selon le fond, contraste ≥ 12:1 vérifié en test | Fait (v0.5) |
| `color-scheme` et `theme-color` suivent le thème | Fait (v0.5) |
| Numéros d'urgence en liens `tel:` avec `aria-label` | Fait (v0.3) |
| URL reflétant l'état (onglets, filtres) | Partiel (écran seulement) |
