FROM flaudisio/asdf-vm:python-3.10-alpine

LABEL \
    org.opencontainers.image.authors="Flaudísio Tolentino <code+docker-images@flaudisio.com>" \
    org.opencontainers.image.title="pre-commit" \
    org.opencontainers.image.source="https://github.com/flaudisio/docker-images"

WORKDIR /project

ARG pre_commit_version

RUN set -ex \
 && apk add --no-cache \
        bash \
        ca-certificates \
        curl \
        gcc \
        git \
        libc-dev \
        make \
        perl \
        unzip \
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
 && rm -rf ~/.cache

CMD ["pre-commit", "--version"]
