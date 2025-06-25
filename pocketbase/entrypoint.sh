#!/bin/sh

# Exit on error
set -e

# Check if we are on a preview branch (not main)
if [ -n "$COOLIFY_BRANCH" ] && [ "$COOLIFY_BRANCH" != "main" ]; then
  echo "Preview branch '$COOLIFY_BRANCH' detected. Running db sync..."

  # Check for required environment variables for sync
  if [ -z "$PUBLIC_PB_HOST_PROD" ] || [ -z "$PB_ADMIN_EMAIL" ] || [ -z "$PB_ADMIN_PASSWORD" ]; then
    echo "Missing environment variables for db sync. Skipping."
    echo "Required: PUBLIC_PB_HOST_PROD, PB_ADMIN_EMAIL, PB_ADMIN_PASSWORD"
  else
    # Run the sync script
    node /app/scripts/sync-db.js \
      --host="$PUBLIC_PB_HOST_PROD" \
      --email="$PB_ADMIN_EMAIL" \
      --password="$PB_ADMIN_PASSWORD"
  fi
else
  echo "Branch is main or not specified. Skipping db sync."
fi

echo "Starting PocketBase..."
# Execute the original command
exec /pb/pocketbase serve --http=0.0.0.0:8081 --dir=/app/pb_data --migrationsDir=/app/pb_migrations 