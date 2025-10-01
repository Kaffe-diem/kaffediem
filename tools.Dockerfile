FROM oven/bun:1.2-alpine

ARG PB_VERSION=0.28.4

ADD https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip /tmp/pb.zip
RUN unzip /tmp/pb.zip -d /pb/

RUN apk add --no-cache \
    unzip \
    ca-certificates \
    wget

