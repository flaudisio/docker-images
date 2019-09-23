ARG python_version=3
FROM python:${python_version}-alpine

LABEL maintainer="Flaudísio Tolentino <me@flaudis.io>"

RUN set -eux ; \
    apk add --no-cache \
        tree && \
    pip install \
        cookiecutter && \
    \
    python --version && \
    pip --version && \
    cookiecutter --version && \
    \
    rm -rf ~/.cache

CMD ["cookiecutter", "--version"]
