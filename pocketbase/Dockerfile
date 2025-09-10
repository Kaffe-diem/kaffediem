FROM node:20.11-slim

ARG PB_VERSION=0.28.4

RUN apt-get update && apt-get install -y \
    unzip \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# download and unzip PocketBase
ADD https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip /tmp/pb.zip
RUN unzip /tmp/pb.zip -d /pb/

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY scripts/sync-db.js ./scripts/

# uncomment to copy the local pb_migrations dir into the container
# COPY ./pb_migrations /pb/pb_migrations

# uncomment to copy the local pb_hooks dir into the container
# COPY ./pb_hooks /pb/pb_hooks
EXPOSE 8081
ENV PORT=8081

# start PocketBase
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8081", "--dir=/app/pb_data", "--migrationsDir=/app/pb_migrations", "--origins=https://kaffediem.okpl.us,https://*.kaffediem.okpl.us,https://*.app.github.dev,http://app:3000,http://localhost:5173,http://127.0.0.1:5173,http://0.0.0.127:5173"]