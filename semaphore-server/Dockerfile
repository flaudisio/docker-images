FROM alpine:3.21

# Non-root user

RUN set -ex \
 && addgroup -g 786 semaphore \
 && adduser -D -u 786 -G semaphore semaphore

# Base dependencies

ARG gosu_version=1.17
ARG tini_version=0.19.0

RUN set -ex \
 && DL_ARCH="amd64" \
 && if [ "$( arch )" = "aarch64" ] ; then DL_ARCH="arm64" ; fi \
 && wget -q -O /sbin/gosu "https://github.com/tianon/gosu/releases/download/${gosu_version}/gosu-${DL_ARCH}" \
 && wget -q -O /sbin/tini "https://github.com/krallin/tini/releases/download/v${tini_version}/tini-static-${DL_ARCH}" \
 && chmod -v 755 /sbin/gosu /sbin/tini

# Semaphore

ARG semaphore_version

RUN set -ex \
 && DL_ARCH="amd64" \
 && if [ "$( arch )" = "aarch64" ] ; then DL_ARCH="arm64" ; fi \
 && wget -q -O semaphore.tar.gz \
        "https://github.com/ansible-semaphore/semaphore/releases/download/v${semaphore_version}/semaphore_${semaphore_version}_linux_${DL_ARCH}.tar.gz" \
 && tar -xvz -f semaphore.tar.gz semaphore \
 && rm -f semaphore.tar.gz \
 && mv -v semaphore /usr/local/bin/semaphore \
 && chown -v root:root /usr/local/bin/semaphore \
 && chmod -v 755 /usr/local/bin/semaphore

# Image setup

COPY entrypoint.sh /sbin/entrypoint.sh

ENTRYPOINT ["tini", "--", "/sbin/entrypoint.sh"]

CMD ["semaphore", "server", "--no-config"]
