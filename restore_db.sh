#!/usr/bin/env bash
set -euo pipefail

# Adjust these if needed
FILE="sql_22_jan.backup"
DBNAME='workshift-dev-35' # quoted when used in SQL/psql because of hyphens
PGHOST=localhost
PGPORT=5432
PGUSER=postgres
export PGPASSWORD='postgres' # Uncomment to use password auth (or set ~/.pgpass)

# Start postgres if not running
echo "Ensuring PostgreSQL service is running..."
sudo systemctl start postgresql

# Drop and recreate the database (owner postgres)
echo "Dropping and creating database \"$DBNAME\"..."
psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -c "DROP DATABASE IF EXISTS \"$DBNAME\";"
psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -c "CREATE DATABASE \"$DBNAME\" OWNER $PGUSER;"

# Detect backup format and restore accordingly
if file "$FILE" | grep -iq 'postgre'; then
  echo "Detected PostgreSQL custom dump (pg_dump -Fc or similar). Using pg_restore..."
  pg_restore -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DBNAME" -v "$FILE"
else
  echo "Assuming plain SQL dump. Using psql -f..."
  psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DBNAME" -f "$FILE"
fi

# If we get here, restore succeeded (set -e will have exited on failure).
# Safely delete all rows from notification_tokens only if the table exists.
echo "Restore finished. Checking for notification_tokens table..."
TABLE_EXISTS=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DBNAME" -tAc "SELECT to_regclass('public.notification_tokens');")

if [[ -n "${TABLE_EXISTS//[[:space:]]/}" ]]; then
  echo "Table notification_tokens exists — deleting all records..."
  psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DBNAME" -c "DELETE FROM public.notification_tokens;"
  echo "All records deleted from notification_tokens."
else
  echo "Table notification_tokens does not exist in \"$DBNAME\" — nothing to delete."
fi

echo "Done."
