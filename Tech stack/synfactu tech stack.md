# Logiciel de suivi de facturation et paiement : décisions d'architecture

## Contexte

Outil interne pour une entreprise unipersonnelle, avec possibilité d'accès pour des utilisateurs externes (ex. assistante administrative externalisée). Le logiciel est destiné à terme à être revendu à d'autres entreprises unipersonnelles sous forme de licence par abonnement, livré en auto-hébergement.

---

## Principes directeurs

- Souveraineté des données : toutes les données métier restent sur la machine de l'exploitant, aucun service externe ne stocke les données utilisateurs ou financières.
- Stack homogène : TypeScript de bout en bout, un seul langage sur toute la chaîne.
- Simplicité opérationnelle : un seul fichier `docker-compose.yml`, tout démarre avec `docker compose up`.
- Vélocité : stack éprouvée, bien documentée, compatible Claude Code.
- Progressivité de la base de données : on démarre avec SQLite pour sa simplicité, migration vers PostgreSQL prévue plus tard quand le besoin s'en fera sentir.

---

## Évolution possible

- Base de données : migration de SQLite vers PostgreSQL quand le besoin de scalabilité, d'accès concurrent ou de Row-Level Security se présentera.
- IA : intégration d'Ollama + Mistral (instance externe déjà en place) pour la génération de descriptions de prestations, la rédaction d'emails de relance et le résumé de l'historique client. Non prioritaire pour l'instant.
- Gestion de licences : revente du logiciel à d'autres entreprises unipersonnelles sous forme d'abonnement, avec un serveur de licences séparé (LemonSqueezy + validation au démarrage). Non prioritaire pour l'instant.

---

## Stack technique

| Couche | Choix | Raison |
|---|---|---|
| Framework | Next.js 15 + TypeScript | Full-stack en un seul langage, App Router, API Routes intégrées |
| UI | Tailwind CSS + shadcn/ui | Composants copiés dans le projet, pas de dépendance externe, contrôle total |
| Auth + rôles | Better Auth | Open source, self-hosted, données dans la BDD locale, gestion des rôles et invitations |
| Base de données | SQLite (migration vers PostgreSQL 16 prévue plus tard) | Zéro configuration au démarrage, fichier unique, suffisant pour un usage unipersonnel ou petite équipe, migration vers PostgreSQL prévue via Prisma quand le besoin de scalabilité ou de Row-Level Security se présentera |
| ORM | Prisma | Typage fort, migrations solides, compatible TypeScript natif |
| Export PDF | @react-pdf/renderer | Export de graphiques et statistiques en PDF, templates en JSX, cohérent avec le reste du stack |
| Reverse proxy | Caddy (instance existante, mutualisée, hors de ce `docker-compose.yml`) | HTTPS automatique, configuration minimale, sécurité par défaut, déjà en place pour d'autres services |
| Conteneurisation | Docker Compose | Un seul commande pour tout lancer, portable sur n'importe quelle machine |

---

## Architecture Docker Compose

1 seul service dans le `docker-compose.yml` (pas de service dédié à la base de données, SQLite est un fichier local ; pas de service Caddy, il existe déjà ailleurs) :

```
docker-compose.yml
└── app        (Next.js + Better Auth + Prisma, base SQLite persistée en volume)
```

Le conteneur `app` est rattaché au réseau Docker externe partagé avec l'instance Caddy existante, qui route le trafic HTTPS vers lui via un site block dédié dans sa configuration.

Quand la migration vers PostgreSQL sera faite, un service `postgres` sera ajouté au `docker-compose.yml`, sans autre changement d'architecture (Prisma abstrait déjà la base de données).

---

## Variables d'environnement anticipées

```yaml
environment:
  DATABASE_URL: "file:./data/facturation.db"   # migrera vers une URL postgresql:// lors du passage à PostgreSQL
  BETTER_AUTH_SECRET: ""
```

---

## Gestion des utilisateurs

Better Auth gère nativement :
- l'authentification email + mot de passe
- les rôles (admin, utilisateur restreint)
- les invitations par email
- les sessions

Les données utilisateurs sont stockées dans la base SQLite locale, dans le même conteneur `app`. Aucune donnée ne transite vers un service tiers.
