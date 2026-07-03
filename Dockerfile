# Stage 1: Build
FROM node:24-alpine@sha256:156b55f92e98ccd5ef49578a8cea0df4679826564bad1c9d4ef04462b9f0ded6 AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Strip the native binaries wrangler ships only for local emulation/bundling
# (`wrangler dev` / `deploy`). A remote export (`d1 export --remote`) is pure
# Cloudflare REST API traffic and never spawns them. wrangler still resolves
# their *paths* at startup, so we truncate the files to 0 bytes rather than
# deleting them (require.resolve must still find them). Saves ~130 MB.
#   - workerd:  local Workers runtime  (~107 MB)
#   - esbuild:  Worker code bundler    (~10 MB)
#   - libvips:  sharp image processing (~15 MB)
RUN set -eux; \
    find node_modules -type f \( \
        -path 'node_modules/workerd/bin/workerd' -o \
        -path 'node_modules/@cloudflare/workerd-*/bin/workerd' -o \
        -path 'node_modules/@esbuild/*/bin/esbuild' -o \
        -path 'node_modules/esbuild/bin/esbuild' -o \
        -path 'node_modules/@img/sharp-libvips-*/lib/*.so*' \
    \) -exec sh -c ': > "$1"' _ {} \;

# Stage 2: Production
FROM node:24-alpine@sha256:156b55f92e98ccd5ef49578a8cea0df4679826564bad1c9d4ef04462b9f0ded6
WORKDIR /app
COPY --from=build /app .
COPY backup.sh backup.sh
# Run unprivileged. The node image ships uid/gid 1000 (node); the backup only
# writes to /tmp, so the mounted /tmp/backup volume must be writable by uid 1000.
USER node
CMD ["sh", "backup.sh"]
