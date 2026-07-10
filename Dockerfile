# Stage 1: Build
FROM node:25-alpine@sha256:bdf2cca6fe3dabd014ea60163eca3f0f7015fbd5c7ee1b0e9ccb4ced6eb02ef4 AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Stage 2: Production
FROM node:25-alpine@sha256:bdf2cca6fe3dabd014ea60163eca3f0f7015fbd5c7ee1b0e9ccb4ced6eb02ef4
WORKDIR /app
COPY --from=build /app .
COPY backup.sh backup.sh
# Run unprivileged. The node image ships uid/gid 1000 (node); the backup only
# writes to /tmp, so the mounted /tmp/backup volume must be writable by uid 1000.
USER node
CMD ["sh", "backup.sh"]
