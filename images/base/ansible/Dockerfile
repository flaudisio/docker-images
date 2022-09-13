FROM python:3.7-alpine

LABEL \
    org.opencontainers.image.authors="Flaudísio Tolentino <code+docker-images@flaudisio.com>" \
    org.opencontainers.image.title="Ansible" \
    org.opencontainers.image.source="https://github.com/flaudisio/docker-images"

ARG ansible_version

RUN set -ex \
 && apk add --no-cache \
        git \
 && apk add --no-cache --virtual .build-deps \
        gcc \
        libffi-dev \
        make \
        musl-dev \
        openssl-dev \
 && pip install --no-cache-dir \
        "ansible==${ansible_version}" \
        "boto3==1.*" \
        "pywinrm==0.3.*" \
 && apk del --no-cache --purge .build-deps \
    \
 && python --version \
 && pip --version \
 && git --version \
 && ansible --version \
    \
 && rm -rf ~/.cache

CMD ["ansible", "--version"]
