FROM oven/bun:1.2-alpine

RUN apk add --no-cache \
    unzip \
    ca-certificates \
    wget \
    sqlite

