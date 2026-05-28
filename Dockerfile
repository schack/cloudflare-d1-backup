# Stage 1: Build
FROM node:26-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Stage 2: Production
FROM node:26-alpine
WORKDIR /app
COPY --from=build /app .
COPY backup.sh backup.sh
CMD ["sh", "backup.sh"]
