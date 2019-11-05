ARG parent_image=python:3-alpine
FROM ${parent_image}

LABEL maintainer="Flaudísio Tolentino <me@flaudis.io>"

ARG pre_commit_version="1.*"
ENV PRE_COMMIT_VERSION ${pre_commit_version}

RUN set -eux ; \
    apk add --no-cache \
        bash \
        git ; \
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

COPY run-ci-tests.sh /usr/local/bin/run-ci-tests

CMD ["pre-commit", "--version"]
