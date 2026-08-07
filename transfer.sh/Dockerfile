FROM alpine:3.24

# Base dependencies

ARG gosu_version=1.19
ARG tini_version=0.19.0

RUN set -ex \
 && DL_ARCH="amd64" \
 && if [ "$( arch )" = "aarch64" ] ; then DL_ARCH="arm64" ; fi \
 && wget -q -O /bin/gosu "https://github.com/tianon/gosu/releases/download/${gosu_version}/gosu-${DL_ARCH}" \
 && wget -q -O /bin/tini "https://github.com/krallin/tini/releases/download/v${tini_version}/tini-static-${DL_ARCH}" \
 && chmod -v 755 /bin/gosu /bin/tini

# Transfer

ENV TRANSFER_USER="transfer" \
    BASEDIR="/data" \
    TEMP_PATH="/temp"

RUN set -ex \
 && addgroup -g 522 "$TRANSFER_USER" \
 && adduser -D -u 522 -G "$TRANSFER_USER" "$TRANSFER_USER"

ARG transfer_version

RUN set -ex \
 && DL_ARCH="amd64" \
 && if [ "$( arch )" = "aarch64" ] ; then DL_ARCH="arm64-v8a" ; fi \
 && wget -q -O /bin/transfer \
        "https://github.com/dutchcoders/transfer.sh/releases/download/v${transfer_version}/transfersh-v${transfer_version}-linux-${DL_ARCH}" \
 && chmod -v 755 /bin/transfer

# Image setup

COPY entrypoint.sh /bin/entrypoint.sh

ENTRYPOINT ["tini", "--", "/bin/entrypoint.sh"]

CMD ["transfer"]
