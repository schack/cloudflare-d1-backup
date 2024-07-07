# Stage 1: Build
FROM node:22-alpine AS build
# Set the working directory
WORKDIR /app
# Install Cloudflare Wrangler
RUN npm install wrangler 
# Stage 2: Production
FROM node:22-alpine
# Set the working directory
WORKDIR /app
# Copy only the necessary files from the build stage
COPY --from=build /app .
COPY backup.sh backup.sh
# Define the command to run the application
CMD ["sh", "backup.sh"]