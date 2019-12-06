FROM python:3.7-alpine

LABEL \
    maintainer="Flaudísio Tolentino <code+docker-images@flaudisio.com>" \
    com.flaudisio.image-type="base-image" \
    com.flaudisio.name="MkDocs" \
    com.flaudisio.vcs-ref="https://github.com/flaudisio/docker-images"

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
