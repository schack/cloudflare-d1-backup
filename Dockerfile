# Stage 1: Build
FROM node:24-alpine@sha256:a0b9bf06e4e6193cf7a0f58816cc935ff8c2a908f81e6f1a95432d679c54fbfd AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Stage 2: Production
FROM node:24-alpine@sha256:a0b9bf06e4e6193cf7a0f58816cc935ff8c2a908f81e6f1a95432d679c54fbfd
WORKDIR /app
COPY --from=build /app .
COPY backup.sh backup.sh
# Run unprivileged. The node image ships uid/gid 1000 (node); the backup only
# writes to /tmp, so the mounted /tmp/backup volume must be writable by uid 1000.
USER node
CMD ["sh", "backup.sh"]
