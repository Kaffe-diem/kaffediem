FROM node:22-slim AS base
WORKDIR /app

FROM base AS builder

ARG PUBLIC_BACKEND_URL
ARG PUBLIC_BACKEND_WS
ENV PUBLIC_BACKEND_URL=${PUBLIC_BACKEND_URL}
ENV PUBLIC_BACKEND_WS=${PUBLIC_BACKEND_WS}

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

FROM node:22-slim AS production
ARG PUBLIC_BACKEND_URL
ARG PUBLIC_BACKEND_WS
ENV PUBLIC_BACKEND_URL=${PUBLIC_BACKEND_URL}
ENV PUBLIC_BACKEND_WS=${PUBLIC_BACKEND_WS}
WORKDIR /app
COPY --from=builder /app/build build/
COPY --from=builder /app/node_modules node_modules/
COPY package.json .
EXPOSE 3000
ENV NODE_ENV=production
ENV PORT=3000
CMD ["node", "build"]
