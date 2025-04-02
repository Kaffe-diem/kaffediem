# modified from https://gist.github.com/aradalvand/04b2cad14b00e5ffe8ec96a3afbb34fb
FROM node:20.11-alpine AS builder
WORKDIR /app
COPY package*.json .
RUN npm ci
RUN apk add --no-cache make python3 g++ build-base
COPY . .
RUN npm rebuild sqlite3 --build-from-source
RUN make build
RUN npm prune --production

FROM node:20.11-alpine
WORKDIR /app
COPY --from=builder /app/build build/
COPY --from=builder /app/node_modules node_modules/
COPY package.json .
EXPOSE 3000
ENV NODE_ENV=production
CMD ["node", "build"]
