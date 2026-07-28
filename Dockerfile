# syntax=docker/dockerfile:1.6
# ────────────────────────────────────────────────────────────────────────────
# Wiki scraper image.
#
# Default runtime config targets Turso (hosted libSQL). Local SQLite mode is
# also supported — just leave LIBSQL_URL unset and bind-mount a directory
# onto /app/data so DB_PATH can resolve to a writable file.
#
# Build:   docker build -t wiki-scraper .
# Run OSRS:
#   docker run --rm \
#     -e LIBSQL_URL=libsql://osrs-wiki-XXX.turso.io \
#     -e LIBSQL_AUTH_TOKEN=eyJ... \
#     -e DISCORD_USERNAME=yourname \
#     -v "$PWD/data/osrs:/app/data" \
#     wiki-scraper
# Run RS3 (same image, different env):
#   docker run --rm \
#     -e GAME=rs3 \
#     -e LIBSQL_URL_RS3=libsql://rs3-wiki-XXX.turso.io \
#     -e LIBSQL_AUTH_TOKEN_RS3=eyJ... \
#     -e DISCORD_USERNAME=yourname \
#     -v "$PWD/data/rs3:/app/data/rs3" \
#     wiki-scraper
# ────────────────────────────────────────────────────────────────────────────

# ---- Builder ----------------------------------------------------------------
FROM node:24-slim AS builder
WORKDIR /app

# Install deps first for better layer caching. package-lock.json is the
# source of truth — `npm ci` refuses to run if it's out of sync.
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci

# Copy the rest of the source and compile to ./dist
COPY . .
RUN npm run build


# ---- Runtime ----------------------------------------------------------------
FROM node:24-slim AS runtime
WORKDIR /app

# Install only production dependencies (no dev tooling, no TypeScript, no
# test runners). `form-data` is in dependencies because the page-content
# dumper imports it at runtime.
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

# Compiled output only — no source, no maps.
COPY --from=builder /app/dist ./dist

# Output directories. Mount these as volumes in production so extracted JSON
# survives container restarts. `paths.ts` mkdir's subdirs of these at module
# load, so they must be writable by the unprivileged `node` user.
RUN mkdir -p /app/data /app/data/rs3 /app/wiki-data /app/wiki-data-rs3 && \
    chown -R node:node /app/data /app/data/rs3 /app/wiki-data /app/wiki-data-rs3

# Sensible defaults — all overridable at `docker run` time.
ENV NODE_ENV=production \
    GAME=osrs \
    DATA_FOLDER_PATH=/app/data \
    WIKI_FOLDER_PATH=/app/wiki-data \
    DATA_FOLDER_PATH_RS3=/app/data/rs3 \
    WIKI_FOLDER_PATH_RS3=/app/wiki-data-rs3

# Drop privileges — the `node` user (UID 1000) already exists in the
# node:* images and matches the directory ownership above.
USER node

# `nest build` emits dist/src/main.js (matches the existing `start:prod`
# npm script).
CMD ["node", "dist/src/main.js"]
