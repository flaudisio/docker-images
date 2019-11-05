FROM python:3.7-alpine

LABEL maintainer="Flaudísio Tolentino <me@flaudis.io>"

ARG ansible_version=2.8
ENV ANSIBLE_VERSION ${ansible_version}

RUN set -eux ; \
    apk add --no-cache \
        git ; \
    apk add --no-cache --virtual .build-deps \
        gcc \
        libffi-dev \
        make \
        musl-dev \
        openssl-dev ; \
    pip install \
        "ansible==${ANSIBLE_VERSION}.*" \
        "boto3==1.*" \
        "pywinrm==0.3.*" ; \
    apk del --no-cache --purge .build-deps ; \
    \
    python --version ; \
    pip --version ; \
    git --version ; \
    ansible --version ; \
    \
    rm -rf ~/.cache

CMD ["ansible", "--version"]
