FROM python:3.7-alpine

LABEL maintainer="Flaudísio Tolentino <me@flaudis.io>"

WORKDIR /project

ARG mkdocs_version=1.*
ENV MKDOCS_VERSION ${mkdocs_version}

RUN set -eux ; \
    pip install \
        "mkdocs==${MKDOCS_VERSION}" ; \
    python --version ; \
    pip --version ; \
    mkdocs --version ; \
    \
    rm -rf ~/.cache

CMD ["mkdocs", "--version"]
