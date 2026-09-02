#!/bin/sh
# Bring a deployed instance onto a new version.
#
# The database is backed up FIRST, and the script aborts if that fails.
# The entrypoint applies "prisma migrate deploy" to a file holding years of
# financial data, and a migration is the only step here with no undo.
# Everything after the backup is recoverable; the backup is what makes it so.
#
# Deliberately absent: "docker compose down -v", volume removal and image
# pruning. An operator running this monthly must not be one flag away from
# deleting the database.
set -eu
cd "$(dirname "$0")"

DATA_DIR="${DATA_DIR:-./data}"
BACKUP_DIR="${BACKUP_DIR:-./backups}"
BACKUP_KEEP="${BACKUP_KEEP:-10}"
DB="$DATA_DIR/app.db"

# --- 1. back up, or stop here ------------------------------------------------
if [ ! -f "$DB" ]; then
  echo "no database at $DB - refusing to update an instance I cannot back up"
  exit 1
fi

mkdir -p "$BACKUP_DIR"
DEST="$BACKUP_DIR/app-$(date +%Y%m%d-%H%M%S).db"

if command -v sqlite3 >/dev/null 2>&1; then
  # .backup is consistent against a live database; cp is not.
  sqlite3 "$DB" ".backup '$DEST'"
else
  echo "sqlite3 not found - stopping the container for a consistent copy"
  docker compose stop app
  cp "$DB" "$DEST"
fi

if [ ! -s "$DEST" ]; then
  echo "backup failed or is empty - aborting before any migration runs"
  rm -f "$DEST"
  exit 1
fi
echo "backup written to $DEST"

# --- 2. build and recreate ---------------------------------------------------
before=$(docker compose images app --format '{{.Tag}}' 2>/dev/null || echo "unknown")

docker compose build
docker compose up -d

# --- 3. wait for health ------------------------------------------------------
echo "waiting for health"
i=0
while [ "$i" -lt 60 ]; do
  state=$(docker compose ps --format '{{.Health}}' app 2>/dev/null || echo "")
  case "$state" in
    healthy)
      after=$(docker compose images app --format '{{.Tag}}' 2>/dev/null || echo "unknown")
      echo "healthy - $before -> $after"
      echo "backup: $DEST"
      # --- 4. prune old backups, newest kept --------------------------------
      ls -1t "$BACKUP_DIR"/app-*.db 2>/dev/null \
        | tail -n +"$((BACKUP_KEEP + 1))" \
        | while read -r old; do rm -f "$old"; echo "pruned $old"; done
      exit 0
      ;;
    unhealthy)
      echo "unhealthy after update - the backup is at $DEST"
      echo "logs: docker compose logs app"
      exit 1
      ;;
  esac
  i=$((i + 1)); sleep 2
done

echo "no health answer after 120s - the backup is at $DEST"
echo "logs: docker compose logs app"
exit 1
