FROM python:3.10-alpine

LABEL \
    org.opencontainers.image.authors="Flaudísio Tolentino <code+docker-images@flaudisio.com>" \
    org.opencontainers.image.title="AWS CLI" \
    org.opencontainers.image.source="https://github.com/flaudisio/docker-images"

ARG awscli_version

RUN set -ex \
 && apk add --no-cache \
        bash \
        jq \
        make \
 && pip install --no-cache-dir \
        "awscli==${awscli_version}" \
    \
 && bash --version \
 && jq --version \
 && python --version \
 && pip --version \
 && aws --version \
    \
 && rm -rf ~/.cache

CMD ["aws", "--version"]
