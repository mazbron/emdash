#!/bin/sh
set -e

echo "Starting Docker Entrypoint for EmDash..."

# The demos/simple folder is the primary demo
cd /app/demos/simple

# If data.db does not exist, run bootstrap to initialize db and seed content
if [ ! -f "data.db" ]; then
    echo "data.db not found. Running bootstrap..."
    # Bypass passkey auth during dev setup or run normal init if this is production
    # emdash init will setup the schema, emdash seed will put dummy content in
    # However, running the emdash script using the project's locally built dependencies is safer.
    pnpm --filter emdash-demo bootstrap
else
    echo "Existing data.db found. Skipping bootstrap."
fi

# We might also need to make sure the uploads directory exists
mkdir -p uploads

echo "Starting Astro Node server..."
# The astro server runs via Node
exec node ./dist/server/entry.mjs
