ARG python_version=3
FROM python:${python_version}-alpine

LABEL \
    maintainer="Flaudísio Tolentino <code+docker-images@flaudisio.com>" \
    com.flaudisio.image-type="base-image" \
    com.flaudisio.name="Cookiecutter" \
    com.flaudisio.vcs-ref="https://github.com/flaudisio/docker-images"

RUN set -eux ; \
    apk add --no-cache \
        tree ; \
    pip install \
        cookiecutter ; \
    \
    python --version ; \
    pip --version ; \
    cookiecutter --version ; \
    \
    rm -rf ~/.cache

CMD ["cookiecutter", "--version"]
