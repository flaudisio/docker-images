FROM flaudisio/asdf-vm:python-3.10-slim

LABEL \
    org.opencontainers.image.authors="Flaudísio Tolentino <code+docker-images@flaudisio.com>" \
    org.opencontainers.image.title="pre-commit" \
    org.opencontainers.image.source="https://github.com/flaudisio/docker-images"

WORKDIR /project

ARG pre_commit_version

RUN set -ex \
 && apt-get update -q \
 && apt-get install -q -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        git \
        make \
        perl \
        procps \
        unzip \
        xz-utils \
 && pip install --no-cache-dir \
        "pre-commit==${pre_commit_version}" \
    \
 && bash --version \
 && git --version \
 && python --version \
 && pip --version \
 && pre-commit --version \
    \
 && find /usr/local -depth -type d -name '__pycache__' -exec rm -rf '{}' \; \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf ~/.cache

CMD ["pre-commit", "--version"]
