#!/bin/sh

# Start PocketBase in the background
/pb/pocketbase serve --http=0.0.0.0:8081 --dir=/app/pb_data --migrationsDir=/app/pb_migrations &
PB_PID=$!

# Check if we are on a preview branch (not main)
if [ -n "$COOLIFY_BRANCH" ] && [ "$COOLIFY_BRANCH" != "main" ]; then
  echo "Preview branch '$COOLIFY_BRANCH' detected. Waiting for DB to start before sync..."

  # Wait for PocketBase to be ready by polling the health check endpoint
  echo "Waiting for PocketBase..."
  tries=0
  max_tries=30
  until wget -q --spider http://127.0.0.1:8081/api/health; do
    tries=$((tries+1))
    if [ $tries -ge $max_tries ]; then
      echo "PocketBase failed to start after $max_tries attempts. Exiting."
      exit 1
    fi
    echo "Still waiting... (attempt $tries/$max_tries)"
    sleep 1
  done
  echo "PocketBase is ready."

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

echo "PocketBase started. Watching for process to exit."
# Wait for the PocketBase process to exit
wait $PB_PID 