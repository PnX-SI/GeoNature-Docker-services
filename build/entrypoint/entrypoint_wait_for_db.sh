#!/bin/sh
set -e

echo "Waiting for database to be ready..."
/entrypoint/wait-for-it.sh $POSTGRES_HOST:$POSTGRES_PORT --timeout=30 --strict -- echo "Database is up!"

exec "$@"