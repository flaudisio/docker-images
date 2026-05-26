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

FROM python:3.13-slim

COPY --from=base /usr/bin/gosu /usr/bin/gosu
COPY --from=base /usr/bin/tini /usr/bin/tini
COPY --from=base /usr/bin/semaphore /usr/bin/semaphore

RUN set -ex \
 && apt-get update -q \
 && apt-get install -q -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        openssh-client \
        sshpass \
        tzdata \
 && rm -rf /var/lib/apt/lists/*

ARG ansible_version

COPY requirements.txt /tmp/requirements.txt

RUN set -ex \
 && sed -E -i "s/^(ansible-core *).*/\1==${ansible_version} # Patched by Dockerfile/" /tmp/requirements.txt \
 && pip install --no-cache-dir \
        -r /tmp/requirements.txt \
 && find /usr/local -depth -type d -name '__pycache__' -exec rm -rf '{}' \; \
 && rm -rf ~/.cache

# Image setup

RUN set -ex \
 && addgroup --gid 786 semaphore \
 && adduser --disabled-password --gecos '' --uid 786 --ingroup semaphore semaphore

COPY entrypoint.sh /usr/bin/entrypoint.sh

ENTRYPOINT ["tini", "--", "/usr/bin/entrypoint.sh"]

CMD ["semaphore", "runner", "start", "--no-config"]
