#!/usr/bin/env bash 
set -euo pipefail 
 
# Adjust these if needed 
FILE="sql.backup" 
DBNAME='workshift-dev-33' # quoted when used in SQL/psql because of hyphens 
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
 
