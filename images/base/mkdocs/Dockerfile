FROM python:3.7-alpine

LABEL \
    org.opencontainers.image.authors="Flaudísio Tolentino <code+docker-images@flaudisio.com>" \
    org.opencontainers.image.title="MkDocs" \
    org.opencontainers.image.source="https://github.com/flaudisio/docker-images"

WORKDIR /project

ARG mkdocs_version

RUN set -ex \
 && pip install --no-cache-dir \
        "mkdocs==${mkdocs_version}" \
 && python --version \
 && pip --version \
 && mkdocs --version \
    \
 && rm -rf ~/.cache

CMD ["mkdocs", "--version"]
