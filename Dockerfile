FROM alpine:latest as RELEASE
LABEL de.podewitz.confd.maintainer="nils.podewitz@googlemail.com"

COPY --from=confd:build /usr/local/bin/confd /usr/bin/confd
RUN apk upgrade --no-cache musl
RUN mkdir -p /etc/confd/conf.d && \
        mkdir -p /etc/confd/templates && \
        mkdir -p /tmp/etc/confd/conf.d && \
        mkdir -p /tmp/etc/confd/templates

COPY etc/confd/conf.d/confd.toml /tmp/etc/confd/conf.d/
COPY etc/confd/templates/confd.toml.tmpl /tmp/etc/confd/templates/


