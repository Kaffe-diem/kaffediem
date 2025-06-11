FROM node:20.11-alpine AS builder

ARG PUBLIC_PB_HOST_PROD
ARG PB_ADMIN_EMAIL  
ARG PB_ADMIN_PASSWORD

WORKDIR /app
COPY package*.json .
RUN npm ci
RUN apk add --no-cache make python3 g++ build-base
COPY . .
RUN npm rebuild sqlite3 --build-from-source
RUN make build
RUN npm prune --production

FROM node:20.11-alpine AS development
WORKDIR /app
RUN apk add --no-cache make python3 g++ build-base
COPY package*.json .
RUN npm install
COPY . .
EXPOSE 5173
ENV NODE_ENV=development
CMD ["./node_modules/.bin/vite", "dev", "--host", "0.0.0.0"]

FROM node:20.11-alpine AS production
WORKDIR /app
COPY --from=builder /app/build build/
COPY --from=builder /app/node_modules node_modules/
COPY package.json .
EXPOSE 3000
ENV NODE_ENV=production
ENV PORT=3000
CMD ["node", "build"]
