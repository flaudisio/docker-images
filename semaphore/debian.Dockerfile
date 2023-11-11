FROM python:3.10-slim

# Dependencies

ARG gosu_version=1.16
ARG tini_version=0.19.0

# hadolint ignore=DL3008
RUN set -ex \
 && apt-get update -q \
 && apt-get install -q -y --no-install-recommends \
        ca-certificates \
        curl \
        gettext-base \
        git \
        mariadb-client \
        openssh-client \
        sshpass \
 && rm -rf /var/lib/apt/lists/* \
 && DL_ARCH=amd64 \
 && if [ "$( arch )" = "aarch64" ] ; then DL_ARCH=arm64 ; fi \
 && curl -fL -o /sbin/gosu "https://github.com/tianon/gosu/releases/download/${gosu_version}/gosu-${DL_ARCH}" \
 && curl -fL -o /sbin/tini "https://github.com/krallin/tini/releases/download/v${tini_version}/tini-static-${DL_ARCH}" \
 && chmod -v 755 /sbin/gosu /sbin/tini

# Semaphore

ENV SEMAPHORE_USER=semaphore \
    SEMAPHORE_TMP_PATH=/semaphore/tmp \
    SEMAPHORE_CONFIG_PATH=/semaphore/etc \
    SEMAPHORE_DB_PATH=/semaphore/db

RUN set -ex \
 && addgroup --gid 786 "$SEMAPHORE_USER" \
 && adduser --disabled-password --gecos '' --uid 786 --ingroup "$SEMAPHORE_USER" "$SEMAPHORE_USER"

ARG semaphore_version

RUN set -ex \
 && DL_ARCH=amd64 \
 && if [ "$( arch )" = "aarch64" ] ; then DL_ARCH=arm64 ; fi \
 && curl -fL -o semaphore.tar.gz \
        "https://github.com/ansible-semaphore/semaphore/releases/download/v${semaphore_version}/semaphore_${semaphore_version}_linux_${DL_ARCH}.tar.gz" \
 && tar -xvz -f semaphore.tar.gz semaphore \
 && rm -f semaphore.tar.gz \
 && mv -v semaphore /usr/local/bin/semaphore \
 && chown -v root:root /usr/local/bin/semaphore \
 && chmod -v 755 /usr/local/bin/semaphore

# Ansible

ARG ansible_version

RUN set -ex \
 && pip install --no-cache-dir \
        "ansible-core==${ansible_version}" \
 && find /usr/local -depth -type d -name '__pycache__' -exec rm -rf '{}' \; \
 && rm -rf ~/.cache

# Image setup

# Ref: https://docs.ansible-semaphore.com/administration-guide/configuration#configuration-file
COPY config.json.tpl /etc/config.json.tpl

COPY entrypoint.sh /sbin/entrypoint.sh

VOLUME ["$SEMAPHORE_TMP_PATH"]

ENTRYPOINT ["tini", "--", "/sbin/entrypoint.sh"]

CMD ["semaphore", "server", "--config", "${SEMAPHORE_CONFIG_PATH}/config.json"]
