FROM golang:1.10-alpine AS build

RUN apk --no-cache add \
        git make gcc musl-dev curl
RUN go get github.com/jwilder/docker-gen
WORKDIR /go/src/github.com/jwilder/docker-gen
RUN make get-deps
RUN make all

FROM alpine:3.7

ENV DEBUG=false \
    DOCKER_GEN_VERSION=0.7.4 \
    DOCKER_HOST=unix:///var/run/docker.sock

# Install packages required by the image
RUN apk add --update \
        bash \
        ca-certificates \
        curl \
        jq \
        openssl \
    && rm /var/cache/apk/*

# Install docker-gen
COPY --from=build /go/src/github.com/jwilder/docker-gen/docker-gen /usr/loca/bin/

# Install simp_le
COPY /install_simp_le.sh /app/install_simp_le.sh
RUN chmod +rx /app/install_simp_le.sh && sync && /app/install_simp_le.sh && rm -f /app/install_simp_le.sh

COPY /app/ /app/

WORKDIR /app

ENTRYPOINT [ "/bin/bash", "/app/entrypoint.sh" ]
CMD [ "/bin/bash", "/app/start.sh" ]
