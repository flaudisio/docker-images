ARG python_version=3
FROM python:${python_version}-alpine

LABEL \
    org.opencontainers.image.authors="Flaudísio Tolentino <code+docker-images@flaudisio.com>" \
    org.opencontainers.image.title="Cookiecutter" \
    org.opencontainers.image.source="https://github.com/flaudisio/docker-images"

RUN set -ex \
 && apk add --no-cache \
        tree \
 && pip install --no-cache-dir \
        cookiecutter \
    \
 && python --version \
 && pip --version \
 && cookiecutter --version \
    \
 && rm -rf ~/.cache

CMD ["cookiecutter", "--version"]
