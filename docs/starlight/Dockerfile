# Multi-stage build for Kaffediem documentation
FROM node:20-alpine AS base

WORKDIR /app

# Install git (required by some npm dependencies)
RUN apk add --no-cache git

# Copy package files
COPY package*.json ./

# Install dependencies
# Remove package-lock.json and use npm install to properly handle optional dependencies on Alpine
RUN rm -f package-lock.json && npm install

# Development stage - run dev server
FROM base AS development

EXPOSE 4321

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]

# Builder stage - build static site
FROM base AS builder

# Copy source files
COPY . .

# Build the static site
RUN npm run build

# Production stage - serve with nginx
FROM nginx:alpine AS production

# Copy built site from builder
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
