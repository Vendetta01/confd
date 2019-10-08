FROM golang:1.10.2-alpine as BUILD

ARG CONFD_GOOS=linux
ARG CONFD_GOARCH=amd64

ENV CONFD_GIT_URL=https://github.com/VendettA01/confd.git

RUN apk add --no-cache bzip2 make upx git
RUN  mkdir -p /go/src/github.com/kelseyhightower/confd
RUN git clone ${CONFD_GIT_URL} /go/src/github.com/kelseyhightower/confd
WORKDIR /go/src/github.com/kelseyhightower/confd
RUN GOOS=${CONFD_GOOS} GOARCH=${CONFD_GOARCH} CGO_ENABLED=0 make build
RUN cp bin/confd /usr/local/bin/confd

FROM alpine:edge as RELEASE
LABEL local.podewitz.dnsmasq-docker.maintainer="nils.podewitz@googlemail.com"

COPY --from=BUILD /usr/local/bin/confd /usr/bin/confd
RUN mkdir -p /etc/confd/conf.d && \
        mkdir -p /etc/confd/templates && \
        mkdir -p /tmp/etc/confd/conf.d && \
        mkdir -p /tmp/etc/confd/templates


