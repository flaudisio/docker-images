FROM python:3.7-alpine

LABEL \
    maintainer="Flaudísio Tolentino <code+docker-images@flaudisio.com>" \
    com.flaudisio.image-type="base-image" \
    com.flaudisio.name="AWS CLI" \
    com.flaudisio.vcs-ref="https://github.com/flaudisio/docker-images"

ARG awscli_version="1.*"
ENV AWSCLI_VERSION ${awscli_version}

RUN set -eux ; \
    apk add --no-cache \
        bash \
        jq \
        make ; \
    pip install --no-cache-dir \
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
