#!/bin/sh
set -e

echo "Starting Docker Entrypoint for EmDash..."

# The demos/simple folder is the primary demo
cd /app/demos/simple

# We might also need to make sure directories exist
mkdir -p data
mkdir -p uploads

# If data.db does not exist, run bootstrap to initialize db and seed content
if [ ! -f "data/data.db" ]; then
    echo "data.db not found. Running bootstrap..."
    # Bypass passkey auth during dev setup or run normal init if this is production
    # We run the emdash CLI directly to avoid any pnpm binary resolution issues in Alpine
    node /app/packages/core/dist/cli/index.mjs init
    node /app/packages/core/dist/cli/index.mjs seed
else
    echo "Existing data/data.db found. Skipping bootstrap."
fi

# We might also need to make sure the uploads directory exists
mkdir -p uploads

echo "Starting Astro Node server..."
# The astro server runs via Node
exec node ./dist/server/entry.mjs
