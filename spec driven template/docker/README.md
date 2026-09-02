# docker/

Skeleton shipped with the spec-driven template. It is a starting point to
adapt at bootstrap step 10, not a working configuration: every `CHANGEME`
has to be replaced and every pinned version verified.

This folder is the only code the template ships. Everything else is
instructions, because everything else is genuinely project-specific.

## Files

| File | Purpose |
|---|---|
| `Dockerfile` | Multi-stage build. Runtime runs as `node`, carries no dev dependencies, uses Next's standalone output. |
| `docker-compose.yml` | One `app` service, no database service, no proxy service. Joins the external network the existing Caddy instance runs on. |
| `entrypoint.sh` | Applies `prisma migrate deploy`, then starts the server. |
| `restart.sh` | Restarts the container. No build, no migration, nothing written to the database. |
| `update.sh` | Backs up the database, aborts if that fails, then builds, recreates and waits on `/api/health`. |

`.dockerignore` and `.env.example` stay at the repository root. Docker
resolves the first against the build context, and Next.js loads `.env` from
the project root, so an example placed here would be copied where nothing
reads it.

## Placeholders

- `docker-compose.yml`: the compose project name, the image name, and the
  name of the external Caddy network.
- `Dockerfile`: `NODE_VERSION`, which must match `package.json` `engines`
  and `.nvmrc`.
- `next.config` must set `output: "standalone"`, or the last `COPY` of the
  runtime stage has nothing to copy.
- `entrypoint.sh`: verify the Prisma CLI path against the version you pinned.

## Where the database lives

On a host directory, not a Docker-managed volume. `update.sh` has to be able
to copy the file, and you have to be able to put it in your own backup
rotation — neither is practical with a named volume, whose contents sit under
Docker's own storage or, on Docker Desktop, inside a virtual machine.

**Caveat, and it decides your deployment.** A bind mount is correct on a Linux
host. On Docker Desktop for Windows or macOS the mount goes through a
filesystem translation layer where SQLite's file locking is not reliable, and
an unreliable lock on a SQLite database means corruption, not an error
message. On those hosts, either run the container under WSL2 with the data
directory on the Linux filesystem, or switch to a named volume and have
`update.sh` extract its backup with `docker compose cp`. Record whichever you
choose as a D-XXX at bootstrap; the trade-off is real either way and the next
reader deserves to know which one you took.

## Permissions

The runtime user is `node` (uid 1000). With a bind mount the host directory's
ownership wins over the `chown` in the `Dockerfile`, so a directory owned by
someone else leaves the application unable to write. Create it and hand it
over before the first start:

```sh
mkdir -p data backups && sudo chown -R 1000:1000 data
```

## Operating

```sh
cd docker
docker compose up -d     # first start
./restart.sh             # restart, nothing else
./update.sh              # back up, build, recreate, verify
```

`update.sh` reads three variables, each with a default: `DATA_DIR`,
`BACKUP_DIR` and `BACKUP_KEEP`. Neither script runs a destructive Docker
command — no `down -v`, no volume removal, no image pruning. Removing the
volume deletes the database, and a script run monthly must not be one flag
away from that.
