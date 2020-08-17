FROM python:3.8-alpine

LABEL \
    maintainer="Flaudísio Tolentino <code+docker-images@flaudisio.com>" \
    com.flaudisio.image-type="base-image" \
    com.flaudisio.name="pre-commit" \
    com.flaudisio.vcs-ref="https://github.com/flaudisio/docker-images"

WORKDIR /project

ARG pre_commit_version="2.*"
ENV PRE_COMMIT_VERSION ${pre_commit_version}

RUN set -eux ; \
    export PYTHONDONTWRITEBYTECODE=1 ; \
    apk add --no-cache \
        bash \
        git \
        make \
        perl ; \
    pip install \
        "pre-commit==${PRE_COMMIT_VERSION}" ; \
    \
    bash --version ; \
    git --version ; \
    python --version ; \
    pip --version ; \
    pre-commit --version ; \
    \
    rm -rf ~/.cache

CMD ["pre-commit", "--version"]
