# Stage 1: Build
FROM node:24-alpine@sha256:e67514e5d0f6c46656005e1b693b2ec9d52e80b641307de684d4a015ba7a4eaf AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Stage 2: Production
FROM node:24-alpine@sha256:e67514e5d0f6c46656005e1b693b2ec9d52e80b641307de684d4a015ba7a4eaf
WORKDIR /app
COPY --from=build /app .
COPY backup.sh backup.sh
# Run unprivileged. The node image ships uid/gid 1000 (node); the backup only
# writes to /tmp, so the mounted /tmp/backup volume must be writable by uid 1000.
USER node
CMD ["sh", "backup.sh"]
