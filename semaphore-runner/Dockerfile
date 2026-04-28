ARG semaphore_version=undefined

FROM flaudisio/semaphore-server:${semaphore_version} AS base

FROM python:3.13-slim

# Non-root user

RUN set -ex \
 && addgroup --gid 786 semaphore \
 && adduser --disabled-password --gecos '' --uid 786 --ingroup semaphore semaphore

# Base dependencies

COPY --from=base /sbin/gosu /sbin/gosu
COPY --from=base /sbin/tini /sbin/tini
COPY --from=base /usr/local/bin/semaphore /usr/local/bin/semaphore

# Common tools

RUN set -ex \
 && apt-get update -q \
 && apt-get install -q -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        jq \
        openssh-client \
        sshpass \
 && rm -rf /var/lib/apt/lists/*

# Ansible & dependencies

ARG ansible_version

COPY requirements.txt /tmp/requirements.txt

RUN set -ex \
 && sed -E -i "s/^(ansible-core *).*/\1==${ansible_version} # Patched by Dockerfile/" /tmp/requirements.txt \
 && pip install --no-cache-dir \
        -r /tmp/requirements.txt \
 && find /usr/local -depth -type d -name '__pycache__' -exec rm -rf '{}' \; \
 && rm -rf ~/.cache

# Image setup

COPY entrypoint.sh /sbin/entrypoint.sh

ENTRYPOINT ["tini", "--", "/sbin/entrypoint.sh"]

CMD ["semaphore", "runner", "start"]
