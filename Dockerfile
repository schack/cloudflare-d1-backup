# Stage 1: Build
FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Stage 2: Production
FROM node:22-alpine
WORKDIR /app
COPY --from=build /app .
COPY backup.sh backup.sh
CMD ["sh", "backup.sh"]
