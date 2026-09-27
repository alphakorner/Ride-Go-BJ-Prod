# Cadre légal, RGPD et licences

> Informations de travail, pas un avis juridique. Faites valider les mentions légales et les CGU par un professionnel avant le lancement commercial.

## Signalements liés aux forces de l'ordre

> v1.0 : le type s'appelle « Présence des forces de l'ordre » (pastille bleue 👮), toujours présenté comme un **signalement communautaire**, jamais comme une information officielle ; le masquage préfectoral (L130-11) s'applique à l'identique.

| Sujet | Texte | Conséquence dans Volt&Go |
|---|---|---|
| **Radars** | Article **R413-15 (V)** du Code de la route : interdiction des dispositifs qui avertissent ou informent de la localisation des appareils de contrôle. Contravention de 5ᵉ classe, retrait de 6 points, confiscation possible. | **Aucun type « radar »**. Remplacé par « Zone de vigilance », un danger générique qui ne mentionne jamais de radar. Rappel dans l'écran de signalement et les CGU. |
| **Contrôles routiers** | Articles **L130-11, L130-12, R130-12** : signaler un contrôle est **autorisé** (c'est ce que fait Waze), mais le préfet peut ordonner aux services de navigation de masquer les messages des utilisateurs autour de certains contrôles (2 h pour alcool/stupéfiants, 12 h sinon ; 2 km en agglomération, 10 km hors agglomération). Ne pas l'appliquer : 2 ans d'emprisonnement et 30 000 € d'amende pour l'exploitant. | **v0.3 : type « contrôle » activé avec le module de masquage.** Table `blackouts` (point, rayon, début, fin, référence de la réquisition), saisie par un administrateur ; filtrage côté serveur (`reports_in_bbox`) et côté client (`Logic.blackoutHides`). Les dangers restent toujours visibles. **Obligation opérationnelle** : recevoir les réquisitions (adresse de contact déclarée en préfecture) et les saisir sans délai. |
| **Dangers de sécurité routière** | Obstacles, travaux, accidents, chaussée glissante ne peuvent pas faire l'objet d'une interdiction de rediffusion sur le réseau national (L130-11 II). | Ces types sont toujours affichés. |

Sources : [L130-11](https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000039687000/), [L130-12](https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000039687002), [R413-15](https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000025111528/), [QPC 2021-948](https://qpc360.conseil-constitutionnel.fr/code-route-radars).

## Trottinette : débridage, écouteurs, connexion (v0.2, mise à jour v0.4)

| Sujet | Texte | Conséquence dans Volt&Go |
|---|---|---|
| **Débridage** | Article **R311-1** du Code de la route : un EDPM est construit pour **ne pas dépasser 25 km/h**. Une trottinette débridée n'est plus un EDPM mais un véhicule motorisé non réceptionné, interdit sur la voie publique. Pour l'**utilisateur**, les sanctions relevées dans les sources sont une amende pouvant aller jusqu'à 1 500 € et la confiscation du véhicule, sans compter la perte de la couverture d'assurance. | **Aucune fonction de débridage** (ni lecture ni écriture du registre de vitesse maximale). La vitesse de croisière est plafonnée à 25 km/h dans la fiche et dans le profil EDPM. Au-delà de 25 km/h saisis, une alerte cite R311-1. Pour l'**éditeur** d'un outil de débridage, je n'ai **pas trouvé** de sanction spécifique confirmée par les sources : ce point est à faire valider par un juriste avant toute évolution. |
| **Écouteurs** | Article **R412-6-1** : il est interdit de porter à l'oreille tout dispositif émettant du son (écouteurs, oreillettes, casque), **y compris à conduction osseuse**. Amende de 135 € (4ᵉ classe). Seules exceptions : les appareils auditifs et les systèmes intégrés au casque d'un deux-roues motorisé. | Les « Bons réflexes » le disent clairement. Le guidage vocal est prévu pour sortir sur le **haut-parleur du téléphone**. La consigne « écouteurs à conduction osseuse », présente dans le cahier des charges, a été **corrigée**. |
| **Assurance** | La responsabilité civile est **obligatoire** pour un EDPM (Code des assurances, L211-1). | Champ « Assurance » dans la fiche trottinette. |
| **Connexion à la trottinette** | Aucun constructeur n'ouvre d'API tierce ; les protocoles communautaires ne marchent que sur de vieux firmwares non chiffrés. | **Retirée en v0.4** : aucune promesse de lecture, de verrouillage, de sonnerie à distance ou de mise à jour. Les données sont saisies par le client. |

Sources : [R412-6-1 (Légifrance)](https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000041910422), [Réglementation des EDPM (Sécurité routière)](https://www.securite-routiere.gouv.fr/reglementation-liee-aux-modes-de-deplacements/reglementation-des-edpm), [Trottinettes électriques et EDPM (ministère des Transports)](https://www.ecologie.gouv.fr/politiques-publiques/trottinettes-electriques-edpm-reglementation-vigueur). R311-1 : Code de la route, définition de l'EDPM (vitesse maximale par construction de 25 km/h).

## Abonnements et consommation (v0.3)

| Sujet | Texte | Conséquence dans Volt&Go |
|---|---|---|
| **Essai gratuit puis abonnement** | Code de la consommation : information précontractuelle claire sur le prix et la durée (L221-5), pas de prélèvement sans consentement exprès. | 7 jours **sans carte bancaire** ; à la fin, l'app se bloque et **demande** un paiement (aucun prélèvement automatique). Prix TTC affichés sur la landing, les forfaits et la page de paiement. |
| **Reconduction** | **L215-1** : information sur la reconduction tacite. | Pas de reconduction tacite : chaque période (29 jours) est payée activement. Rappel d'échéance à 3 jours. |
| **Résiliation en trois clics** | **L215-1-1** et décret 2023-417. | Réglages → Abonnement → « Me désinscrire » → confirmation. |
| **Frais de désinscription (un mois)** | **R212-1 / R212-2** (clauses présumées abusives) et jurisprudence de la Commission des clauses abusives : des frais de résiliation doivent être **expressément prévus, proportionnés à un coût réel** et ne pas créer un déséquilibre significatif. Un « mois supplémentaire » forfaitaire est **juridiquement risqué** pour un abonnement mensuel sans engagement. | Implémenté comme demandé, mais **configurable** (`CONFIG.billing.cancelFeeMonths`, mettre `0` pour le retirer), affiché avant confirmation et dans les CGU (article 9) avec un badge « clause à faire valider par un juriste ». **Recommandation : faire valider ou retirer avant lancement.** |
| **Paiement** | DSP2 / authentification forte. | Confiée à Revolut (page hébergée). Aucune donnée bancaire ne transite par Volt&Go ; nous stockons le forfait, les dates et la référence de commande. |

Sources : [L215-1](https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000034072591/), [L215-1-1](https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000046190107), [Décret 2023-417](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000047613963), [INC — résiliation en quelques clics](https://www.inc-conso.fr/content/vous-pouvez-resilier-votre-contrat-dabonnement-en-quelques-clics).

## Statut d'hébergeur

Les signalements sont des contenus publiés par les utilisateurs : l'éditeur a un rôle d'hébergeur et doit pouvoir retirer promptement un contenu manifestement illicite qui lui est signalé. Prévu : bouton « Signaler un abus », masquage à 3 alertes, retrait par modérateur, journal de modération.

## RGPD

| Donnée | Base légale | Où | Durée | Minimisation |
|---|---|---|---|---|
| Position en direct | Consentement (permission navigateur, écran d'explication) | Appareil uniquement | Pendant l'utilisation | Jamais envoyée ni stockée côté serveur |
| Point d'un signalement | Exécution du service | Serveur | Expiration + 7 jours | Un point, pas de trace |
| Compte (prénom, e-mail, mot de passe haché) | Contrat | Serveur (Supabase Auth) | Jusqu'à suppression | Prénom seulement |
| Véhicule, préférences, favoris | Contrat | Appareil (serveur en phase 7) | Jusqu'à suppression | — |
| Historique de trajets | Consentement (« Enregistrer mes trajets », désactivé par défaut) | Appareil (v0.2) ; serveur plus tard, avec le même consentement | 60 derniers ; tracé purgé après 1 an côté serveur | Destination, distance, durée, date, vitesse max, batterie départ/arrivée ; **tracé simplifié à 400 points au plus**, supprimable trajet par trajet |
| Fiche trottinette | Contrat | Appareil (v0.2) ; table `vehicles` plus tard | Jusqu'à suppression | Marque, modèle, caractéristiques, entretien, assureur ; **aucun numéro de série exigé** |
| Abonnement | Contrat | Appareil (jeton) ; serveur (`subscriptions`, `payments`) écrit par le Worker | Durée du contrat + obligations comptables | Forfait, dates, référence de commande Revolut ; **aucune donnée bancaire** |
| Ordres préfectoraux | Obligation légale (L130-11) | Serveur (`blackouts`) | Durée de l'ordre | Zone et période ; aucune donnée personnelle |
| Photo de la trottinette (client) | Consentement (action explicite) | Appareil | Jusqu'à retrait | Image réduite et compressée, jamais envoyée |
| Carnet d'entretien | Contrat | Appareil | Jusqu'à suppression | Type, date, compteur, atelier, coût, note ; 200 lignes max |

Droits exercés dans l'app : accès et portabilité (Profil → Exporter mes données, JSON), effacement (Profil → Supprimer mon compte ; signalements actifs anonymisés), arrêt de la localisation (Profil → Localisation).

À compléter avant production : SIRET dans les mentions légales, registre des traitements, contrat de sous-traitance Supabase (DPA), choix d'une région UE pour le projet Supabase.

## Licences des données

| Donnée | Licence | Attribution affichée |
|---|---|---|
| OpenStreetMap (tuiles, lieux, ateliers, recharges) | ODbL | Oui (carte + fiches + « Sources des données ») |
| OpenMapTiles / OpenFreeMap | BSD / CC-BY | Oui (automatique MapLibre) |
| Aménagements cyclables BNAC, Eurométropole | Open data data.strasbourg.eu | Oui |
| Base Adresse Nationale (IGN) | Licence Ouverte | Oui |
| MapLibre GL JS | BSD-3 | Dans le code |
| Orthophotos IGN (Géoplateforme, WMTS) | Licence Ouverte (Etalab 2.0) | Oui (« Orthophotos © IGN / Géoplateforme » sur la carte) |
| Photos de modèles (Wikimedia Commons) | Licence propre à chaque fichier (CC0, CC BY, CC BY-SA…), affichée avec l'auteur | Oui, sous la photo ; aucune photo constructeur reprise |
| Terrain Tiles (AWS Open Data, Mapzen) : SRTM, EU-DEM, etc. | Attributions multiples, libres | Oui (attribution de la carte en mode relief) |
| Calques Eurométropole v0.9 : stations de tram, stationnement vélo, stations Vélhop (GBFS), flux trafic SIRAC, programmation des travaux, alertes de circulation | Licence Ouverte (Etalab 2.0), data.strasbourg.eu | Oui (fiche de chaque point + panneau « Calques et carte ») |
| Fontaines à eau, arrêts de bus (OpenStreetMap via Overpass) | ODbL | Oui (fiche + panneau) |
| Météo et qualité de l'air (Open-Meteo : Météo-France AROME, DWD ICON, CAMS Copernicus) | CC BY 4.0 (usage non commercial gratuit ; **abonnement Open-Meteo requis avant tout lancement commercial**, ≈ 29 €/mois) | Oui (fiche météo : « Source : Open-Meteo.com ») |
| Three.js | MIT | Dans le code |

Avis : aucun avis n'est copié d'autres plateformes. Leurs conditions interdisent en général la reprise, et l'API Places de Google est payante et encadrée.
