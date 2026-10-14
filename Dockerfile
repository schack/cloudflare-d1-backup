# Stage 1: Build
FROM node:24-alpine@sha256:ebfe2f90462722a7a4de65e91990e97fe0d401c70e0e762c5b53302f905ec1c1 AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Stage 2: Production
FROM node:24-alpine@sha256:ebfe2f90462722a7a4de65e91990e97fe0d401c70e0e762c5b53302f905ec1c1
WORKDIR /app
COPY --from=build /app .
COPY backup.sh backup.sh
# Run unprivileged as the node image's uid/gid 1000 (node), numeric so the host
# can resolve it. The backup only writes to /tmp, so the mounted /tmp/backup
# volume must be writable by uid 1000.
USER 1000:1000
CMD ["sh", "backup.sh"]
