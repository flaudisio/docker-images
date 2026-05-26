FROM alpine:3.23 AS base

ARG gosu_version=1.19
ARG tini_version=0.19.0

RUN set -ex \
 && DL_ARCH="amd64" \
 && if [ "$( arch )" = "aarch64" ] ; then DL_ARCH="arm64" ; fi \
 && wget -q -O /usr/bin/gosu "https://github.com/tianon/gosu/releases/download/${gosu_version}/gosu-${DL_ARCH}" \
 && wget -q -O /usr/bin/tini "https://github.com/krallin/tini/releases/download/v${tini_version}/tini-static-${DL_ARCH}" \
 && chmod -v 755 /usr/bin/gosu /usr/bin/tini

ARG semaphore_version

RUN set -ex \
 && DL_ARCH="amd64" \
 && if [ "$( arch )" = "aarch64" ] ; then DL_ARCH="arm64" ; fi \
 && wget -q -O semaphore.tar.gz \
        "https://github.com/ansible-semaphore/semaphore/releases/download/v${semaphore_version}/semaphore_${semaphore_version}_linux_${DL_ARCH}.tar.gz" \
 && tar -xvz -f semaphore.tar.gz semaphore \
 && rm -f semaphore.tar.gz \
 && mv -v semaphore /usr/bin/semaphore \
 && chown -v root:root /usr/bin/semaphore \
 && chmod -v 755 /usr/bin/semaphore

FROM alpine:3.23

COPY --from=base /usr/bin/gosu /usr/bin/gosu
COPY --from=base /usr/bin/tini /usr/bin/tini
COPY --from=base /usr/bin/semaphore /usr/bin/semaphore

RUN set -ex \
 && apk add --no-cache \
        bash \
        ca-certificates \
        git \
        tzdata

# Image setup

RUN set -ex \
 && addgroup -g 786 semaphore \
 && adduser -D -u 786 -G semaphore semaphore

COPY entrypoint.sh /usr/bin/entrypoint.sh

ENTRYPOINT ["tini", "--", "/usr/bin/entrypoint.sh"]

CMD ["semaphore", "server", "--no-config"]
