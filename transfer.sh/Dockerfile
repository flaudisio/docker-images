FROM alpine:3.21

# Base dependencies

ARG gosu_version=1.17
ARG tini_version=0.19.0

RUN set -ex \
 && apk add --no-cache \
        bash \
        ca-certificates \
        curl \
 && DL_ARCH="amd64" \
 && if [ "$( arch )" = "aarch64" ] ; then DL_ARCH="arm64" ; fi \
 && curl -fL -o /sbin/gosu "https://github.com/tianon/gosu/releases/download/${gosu_version}/gosu-${DL_ARCH}" \
 && curl -fL -o /sbin/tini "https://github.com/krallin/tini/releases/download/v${tini_version}/tini-static-${DL_ARCH}" \
 && chmod -v 755 /sbin/gosu /sbin/tini

# Transfer

ENV TRANSFER_USER=transfer \
    BASEDIR=/data \
    TEMP_PATH=/temp

RUN set -ex \
 && addgroup -g 522 "$TRANSFER_USER" \
 && adduser -D -u 522 -G "$TRANSFER_USER" "$TRANSFER_USER"

ARG transfer_version

RUN set -ex \
 && DL_ARCH="amd64" \
 && if [ "$( arch )" = "aarch64" ] ; then DL_ARCH="arm64-v8a" ; fi \
 && curl -fL -o transfer \
        "https://github.com/dutchcoders/transfer.sh/releases/download/v${transfer_version}/transfersh-v${transfer_version}-linux-${DL_ARCH}" \
 && mv -v transfer /usr/local/bin/transfer \
 && chown -v root:root /usr/local/bin/transfer \
 && chmod -v 755 /usr/local/bin/transfer

# Image setup

COPY entrypoint.sh /sbin/entrypoint.sh

ENTRYPOINT ["tini", "--", "/sbin/entrypoint.sh"]

CMD ["transfer"]
