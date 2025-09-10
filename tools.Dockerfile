FROM node:20.11-slim

RUN apt-get update && apt-get install -y \
    unzip \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*


