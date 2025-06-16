FROM ghcr.io/coollabsio/pocketbase:latest

RUN mkdir -p /app/pb_data

COPY ./pb_migrations /app/pb_migrations

# uncomment to copy the local pb_hooks dir into the container
# COPY ./pb_hooks /app/pb_hooks

WORKDIR /app

EXPOSE 8081

ENTRYPOINT ["/app/pocketbase", "serve", "--http=0.0.0.0:8081", "--dir=/app/pb_data", "--origins=http://localhost:5173,http://app:5173"]
