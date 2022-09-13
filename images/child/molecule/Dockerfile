ARG base_image_repo
ARG base_image_tag

FROM ${base_image_repo}:${base_image_tag}

LABEL \
    org.opencontainers.image.authors="Flaudísio Tolentino <code+docker-images@flaudisio.com>" \
    org.opencontainers.image.title="Molecule" \
    org.opencontainers.image.source="https://github.com/flaudisio/docker-images"

ARG molecule_version

# We use the (arbitrary) prefix 'DKR_' to keep the 'MOLECULE_' namespace clean
# Ref: https://github.com/ansible/molecule/blob/2.22/molecule/interpolation.py#L56-L59
ENV DKR_MOLECULE_EXTRAS="docker,ec2"

RUN set -ex \
 && apk add --no-cache \
        docker-cli \
 && apk add --no-cache --virtual .build-deps \
        gcc \
        libffi-dev \
        make \
        musl-dev \
        openssl-dev \
 && pip install --no-cache-dir \
        "molecule[${DKR_MOLECULE_EXTRAS}]==${molecule_version}" \
 && apk del --no-cache --purge \
        .build-deps \
    \
 && python --version \
 && pip --version \
 && ansible --version \
 && molecule --version \
 && ansible-lint --version \
 && yamllint --version \
    \
 && rm -rf ~/.cache

CMD ["molecule", "--version"]
