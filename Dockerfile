# Base image with pnpm via corepack
FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# Dependencies setup
FROM base AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
# Copy workspace packages package.jsons to leverage cache if possible
COPY packages packages/
COPY demos demos/
COPY templates templates/
# This ensures that we install dependencies efficiently and SSR modules resolve
RUN echo "shamefully-hoist=true" >> .npmrc
RUN pnpm install --frozen-lockfile

# Builder
FROM deps AS builder
WORKDIR /app
COPY . .
# Emdash requires all packages to be built first, then we build the demo
RUN pnpm build
RUN pnpm --filter emdash-demo build

# Runner
FROM base AS runner
WORKDIR /app
COPY --from=builder /app /app

# Ensure entrypoint script is executable
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

# Expose Host and Port correctly for astro node adapter
ENV HOST=0.0.0.0
ENV PORT=3000
EXPOSE 3000

# Set Node environment
ENV NODE_ENV=production

ENTRYPOINT ["/app/docker-entrypoint.sh"]
