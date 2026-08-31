# SynFactu : questions-reponses de cadrage

Recapitulatif des questions posees par Claude et des reponses de Nassim, dans l'ordre des echanges.

## Modele de donnees (MCD)

**Q : Quelle notation pour le MCD ?**
R : Merise + diagramme Mermaid.

**Q : Le MCD doit il inclure les entites Utilisateur / Role des maintenant ?**
R : Oui, des maintenant.

## Premiere serie : trous de la spec fonctionnelle

**Q1 : Comment gerer la numerotation des factures micro ?**
R : Un modele de numerotation sera propose : 2026-01-001_Client_mission. La mission, c'est quelques mots tres courts.

**Q2 : Le logiciel doit il produire le document de facture (PDF), ou seulement suivre les donnees ?**
R : Suivi des donnees seulement.

**Q3 : Sur quelle date de reference calculer le delai de paiement moyen ?**
R : Pour les factures de la micro, a partir de la date de la facture. Pour le portage salarial, a partir du debut du mois concerne par la facturation.

**Q4 : Quand l'estimation brut/net doit elle etre remplacee par le net reel ?**
R : Au paiement complet.

**Q5 : Comment determiner le "mois de facturation" d'une saisie de temps (parfois different de la date de travail) ?**
R : Choisi manuellement a la saisie.

**Q6 : Pour le TJM reel / taux de facturation reel, quel temps compte au denominateur ?**
R : Tout le temps, facturable ou non.

**Q7 : Comment gerer le seuil de TVA de la micro (franchise en base) ?**
R : Il faudra l'integrer dans les alertes. Les alertes sont a specifier plus tard. Il y aura un tableau de bord qui contiendra une barre d'avancement par rapport au seuil.

**Q8 : Comment le net reel du portage entre dans le logiciel ?**
R : Saisie manuelle depuis le bulletin.

**Q9 : Comment suivre les factures/declarations en retard de paiement ?**
R : Signalement dans le tableau de bord.

**Q10 : Faut il un historique des modifications (qui a change quoi), notamment vu le futur role assistant ?**
R : Journal d'audit.

## Etalement, encours a facturer et paiements multiples

**Q : L'etalement porte sur la facturation, sur le paiement, ou les deux ?**
R : Je veux pouvoir traquer le temps au reel. Ensuite, je facture potentiellement en plusieurs fois ce temps, pour que mon client paye. Mais il est possible qu'une facture aussi soit payee en plusieurs fois, parce que mon client me le dit apres.

**Q : Comment l'"encours a facturer" est il alimente ?**
R : Je ne comprends pas, il faudra que tu me detailles ca. (Explique ensuite : l'encours a facturer = le travail deja realise et valorise mais pas encore mis sur une facture.)

**Q : L'echeancier (montants prevus dans le temps) doit il etre planifie avec suivi des echeances ?**
R : Pas de gestion d'echeancier, juste le delta entre ce qui doit etre facture et ce qui a ete facture, idem pour la partie paiement.

**Q : D'ou vient le montant "a facturer" (la valeur du travail realise) ?**
R : Je ne comprends pas. (Reformule ensuite en : as tu des missions a prix fixe ?)

**Q : Est ce que tu as des missions a prix fixe (forfait), ou est ce que tout est facture au temps passe x TJM ?**
R : Les deux existent.
