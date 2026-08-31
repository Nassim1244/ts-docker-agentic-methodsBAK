# Bilan

Etat de ma comprehension a date. Sert de point de reprise pour continuer la session au propre.

Documents de reference :

- Besoin : `Besoin/Description besoin.txt`
- Decisions de cadrage : `Besoin/Questions-Réponses.md`
- Resume metier : `Besoin/Résumé de Claude.txt`
- Spec fonctionnelle : `Spécification fonctionnelle/docs/Spécification fonctionnelle v1.md` (V1)
- Spec technique : `Spécification technique/Spécification technique v1.md` (V1)
- Modele de donnees : `Spécification fonctionnelle/docs/MCD.md`

## Spec fonctionnelle v1

L'outil remplace l'Excel actuel par un logiciel de facturation avec tableau de bord, base de donnees unique multi annees.

Deux regimes strictement separes : micro entreprise (~25% de charges) et portage salarial (~50%). Le passage brut vers net est une estimation a la facturation, remplacee par le net reel au paiement complet ; le net portage est saisi manuellement depuis le bulletin.

Clients et partenaires distincts : un client final peut etre rattache a un partenaire (lien optionnel). Un client peut avoir plusieurs TJM selon la prestation. Flags `billable` et `active`.

Missions de plusieurs types : au temps (TJM), intervention devant client (suivi du temps non facture pour le taux reel), forfait (montant convenu, temps suivi pour le TJM reel), formation (sous traitance ou direct). Une mission peut etre inactive : elle est masquee des listes de saisie mais conservee.

Saisie du temps : journal ligne par ligne, mois de facturation choisi manuellement, TJM applique et CA calcule. Les saisies facturables sont reliees a la facture/declaration qui les couvre.

Encours et etalement : montant a facturer = valeur du travail (temps x TJM, ou montant forfait) moins ce qui est deja facture ; reste a payer = facture moins paiements. Facturation et paiement possibles en plusieurs fois, sans echeancier planifie, on suit seulement les deux deltas.

Facturation micro : numerotation sur le modele `2026-01-001_Client_mission` (mission en quelques mots tres courts), suivi des donnees seulement, pas de generation de PDF.

Declaration portage : ventilation heures/jours/CA par partenaire et client, par mois.

Paiements : rattaches a une facture micro OU a une paye de portage (exclusif), plusieurs paiements possibles.

URSSAF micro : releve mensuel distinguant cotisations + CFP (impot societe) et versement liberatoire (impot revenu) ; base = somme des paiements micro du mois, paiements relies au releve.

TVA : pas de gestion de TVA, barre d'avancement vers le seuil au tableau de bord, alerte a specifier plus tard.

Tableau de bord : indicateurs (CA, brut, net, a facturer, a payer, delai de paiement, TJM reel, taux de facturation reel), filtres temporels et par client/partenaire/regime/type, graphiques, signalement des retards. Delai de paiement : micro depuis la date de facture, portage depuis le debut du mois facture. TJM reel calcule sur tout le temps, facturable ou non.

Utilisateurs : roles prevus des le depart, administrateur (tout) et assistant externalise (acces restreint), journal d'audit des modifications. Implementation effective plus tard.

Reprise d'historique Excel : souhaitee, a cadrer plus tard.

## Spec technique v1

Encore au stade des intentions, le detail est reporte a une seconde phase.

Type de logiciel : application web. Deploiement dans un environnement Docker, sur Windows ou sur VPS. Mono utilisateur pour l'instant, avec roles prevus.

Stack candidate : React + TypeScript en frontend, shadcn/ui pour les composants. Backend, base de donnees, authentification et architecture restent a definir.

---

# Points ouverts

Liste a traiter avant de considerer les specs et le MCD comme termines.

## Spec fonctionnelle v1 — décisions prises (2026-07-31)

- **Partenaire aussi client** : PARTNER et CLIENT restent des entités séparées ; un partenaire facturé en direct obtient un CLIENT associé. (RG-01)
- **Placement du régime** : régime par défaut sur le CLIENT, surchargeable sur la MISSION. (RG-13)
- **Périmètre base URSSAF** : tous les paiements micro du mois, aucune exclusion. (RG-08, confirmé)
- **Prestations par mission** : une mission = une prestation/TJM ; changement de prestation = nouvelle mission. (RG-02)
- **Numérotation des factures** : séquence `001` remise à zéro chaque mois (`2026-01-001_Client_mission`). (RG-14)
- **Statuts facture/déclaration** : Brouillon -> Envoyée -> Payée partiellement -> Payée ; "en retard" reste un flag calculé au tableau de bord, pas un statut stocké. (RG-15)
- **Rattachement des saisies à une facture** : sélection automatique des saisies facturables non rattachées, ajustable par l'utilisateur avant validation. (RG-16)
- **Règles d'arrondi du temps** : paramétrable dans les options de l'appli, quart d'heure par défaut. (RG-17)
- **Taxonomie des tags** : liste prédéfinie + ajout libre, hiérarchie via `::` (ex. `commercial::RDV1`). (RG-18)
- **Articulation déclaration portage / bulletin réel** : le net réel est saisi manuellement dès réception du bulletin, inchangé par rapport à la spec initiale.
- **Matrice de permissions (rôle assistant)** : volontairement laissée pour plus tard, non détaillée maintenant.

## Spec fonctionnelle v1 — décisions prises (2026-07-31, taux de régime historisé)

- **Historisation du taux de charge** : nouvelle entité REGIME_RATE (taux + `valid_from`/`valid_to`) ; REGIME ne porte plus un taux unique fixe, car le taux légal/contractuel peut changer dans le temps. (RG-19)
- **Date de référence du taux appliqué** : le taux gelé sur une facture/déclaration est celui en vigueur à la **date de création du document**, pas le mois facturé. (RG-20)
- **Nommage et symétrie du champ** : le champ est renommé `estimated_charge_rate` (et non `charge_rate`), ajouté aussi bien sur MICRO_INVOICE que sur PORTAGE_DECLARATION (absent auparavant sur cette dernière).
- **Alerte changement de taux** : différée en V1 ; un taux futur se saisit à l'avance avec sa date `valid_from` et s'applique automatiquement le moment venu, sans notification. (RG-21)

## Spec fonctionnelle v1 — décisions prises (2026-07-31, taux réel vs estimé)

- **Emplacement du taux réel** : le taux/net réel ne se pose pas sur MICRO_INVOICE ni PORTAGE_DECLARATION, mais sur PAYMENT (un paiement micro ou un salaire de portage), car une facture/déclaration peut être réglée en plusieurs paiements, chacun avec son propre taux réel. (RG-22)
- **Micro** : `actual_charge_rate`/`actual_net` sur PAYMENT sont **auto-calculés** dès que le relevé URSSAF du mois est finalisé (tous les paiements du même relevé héritent du même taux réel) ; `amount` reste le montant brut encaissé, pas le net.
- **Portage** : `actual_charge_rate` sur PAYMENT est dérivé une fois le bulletin de paie saisi ; pas de champ `actual_net` séparé, car `amount` est déjà le salaire net réellement perçu (pas de doublon).
- **Réconciliation** : un paiement est "réconcilié" simplement quand `actual_charge_rate` n'est pas nul ; pas de flag séparé. Un taux réel agrégé au niveau facture/déclaration, si besoin pour les stats, se calcule à la volée (moyenne pondérée par montant sur les paiements réconciliés), jamais stocké sur le document. (RG-23)

## Spec fonctionnelle v1 — décision prise (formation = propriété de mission)

- **Formation n'est pas un flux de facturation** : c'est une propriété transverse de la mission (`is_training`), indépendante du `billing_type` (renommé depuis `mission_type` : `temps passé` / `temps sur site` / `forfait`) qui sert à facturer. Le but est de pouvoir lister facilement toutes les missions de formation sur une année. (RG-24, RG-25)
- **Périmètre V1** : simple flag booléen `is_training` sur MISSION. La distinction sous-traitance/direct (`training_mode`) et l'outillage complet pour la Déclaration d'Activité de Formation restent différés.

## Spec fonctionnelle v1 — reste différé

- Spécification des alertes (seuil TVA, retards, échéances, changement de taux de régime) : reportée, à détailler.
- Matrice de permissions et périmètre précis du rôle assistant : à définir quand le rôle sera implémenté.
- Formation en direct : distinction sous-traitance/direct et classification pour la Déclaration d'Activité (plus tard) ; V1 n'a que le flag `is_training`.
- Périmètre et timing de la reprise d'historique Excel.

## Spec technique v1

- Langage et framework backend.
- Moteur de base de donnees (doit porter la base unique multi annees).
- Solution d'authentification et d'autorisation (modele de roles).
- Architecture applicative (couches, API, modules).
- Details de conteneurisation et de deploiement (contraintes Windows vs VPS).
- Integrations : Google Agenda (pre remplissage), export comptable eventuel.
- Strategie de sauvegarde et de persistance.
- Securite des donnees financieres.
- Journalisation et observabilite.
- Outillage de migration pour l'import Excel.
