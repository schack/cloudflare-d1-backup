# Stage 1: Build
FROM node:24-alpine@sha256:156b55f92e98ccd5ef49578a8cea0df4679826564bad1c9d4ef04462b9f0ded6 AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Stage 2: Production
FROM node:24-alpine@sha256:156b55f92e98ccd5ef49578a8cea0df4679826564bad1c9d4ef04462b9f0ded6
WORKDIR /app
COPY --from=build /app .
COPY backup.sh backup.sh
# Run unprivileged. The node image ships uid/gid 1000 (node); the backup only
# writes to /tmp, so the mounted /tmp/backup volume must be writable by uid 1000.
USER node
CMD ["sh", "backup.sh"]
