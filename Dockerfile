# Stage 1: Build
FROM node:24-alpine@sha256:50c8e8ca1d27439048670df5883f32d57cf81cff6233222c893fd0d9884cbd81 AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Stage 2: Production
FROM node:24-alpine@sha256:50c8e8ca1d27439048670df5883f32d57cf81cff6233222c893fd0d9884cbd81
WORKDIR /app
COPY --from=build /app .
COPY backup.sh backup.sh
# Run unprivileged as the node image's uid/gid 1000 (node), numeric so the host
# can resolve it. The backup only writes to /tmp, so the mounted /tmp/backup
# volume must be writable by uid 1000.
USER 1000:1000
CMD ["sh", "backup.sh"]
