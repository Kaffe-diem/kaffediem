FROM node:20.11-slim AS base
WORKDIR /app

FROM base AS builder

ARG PUBLIC_PB_HOST_PROD
ARG PB_ADMIN_EMAIL  
ARG PB_ADMIN_PASSWORD

WORKDIR /app
COPY package*.json .
RUN npm ci
COPY . .
RUN npx vite build
RUN npm prune --omit=dev

FROM base AS development
WORKDIR /app
COPY package*.json .
RUN npm install
COPY . .
EXPOSE 5173
ENV NODE_ENV=development
CMD ["./node_modules/.bin/vite", "dev", "--host", "0.0.0.0"]

FROM node:20.11-slim AS production
WORKDIR /app
COPY --from=builder /app/build build/
COPY --from=builder /app/node_modules node_modules/
COPY package.json .
EXPOSE 3000
ENV NODE_ENV=production
ENV PORT=3000
CMD ["node", "build"]
