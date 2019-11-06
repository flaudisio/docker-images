FROM python:3.7-alpine

LABEL maintainer="Flaudísio Tolentino <me@flaudis.io>"

ARG awscli_version="1.*"
ENV AWSCLI_VERSION ${awscli_version}

RUN set -eux ; \
    apk add --no-cache \
        bash \
        jq ; \
    pip install \
        "awscli==${AWSCLI_VERSION}" ; \
    \
    bash --version ; \
    jq --version ; \
    python --version ; \
    pip --version ; \
    aws --version ; \
    \
    rm -rf ~/.cache

CMD ["aws", "--version"]
