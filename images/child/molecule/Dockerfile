ARG base_image=flaudisio/ansible:latest
FROM ${base_image}

LABEL \
    maintainer="Flaudísio Tolentino <code+docker-images@flaudisio.com>" \
    com.flaudisio.image-type="child-image" \
    com.flaudisio.name="Molecule" \
    com.flaudisio.vcs-ref="https://github.com/flaudisio/docker-images"

ARG molecule_version=2
# We use the (arbitrary) prefix 'DKR_' to keep the 'MOLECULE_' namespace clean
# Ref: https://github.com/ansible/molecule/blob/2.22/molecule/interpolation.py#L56-L59
ENV DKR_MOLECULE_VERSION ${molecule_version}

ENV DKR_MOLECULE_EXTRAS="docker,ec2"

RUN set -eux ; \
    apk add --no-cache \
        docker-cli ; \
    apk add --no-cache --virtual .build-deps \
        gcc \
        libffi-dev \
        make \
        musl-dev \
        openssl-dev ; \
    pip install \
        "molecule[${DKR_MOLECULE_EXTRAS}]==${DKR_MOLECULE_VERSION}.*" ; \
    apk del --no-cache --purge \
        .build-deps ; \
    \
    python --version ; \
    pip --version ; \
    ansible --version ; \
    molecule --version ; \
    ansible-lint --version ; \
    yamllint --version ; \
    \
    rm -rf ~/.cache

CMD ["molecule", "--version"]
