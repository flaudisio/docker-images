ARG base_image_repo
ARG base_image_tag

FROM ${base_image_repo}:${base_image_tag}

LABEL \
    org.opencontainers.image.authors="Flaudísio Tolentino <code+docker-images@flaudisio.com>" \
    org.opencontainers.image.title="ASDF-VM" \
    org.opencontainers.image.source="https://github.com/flaudisio/docker-images"

RUN set -ex \
 && apt-get update -q \
 && apt-get install -q -y --no-install-recommends \
        bash \
        curl \
        curl \
        git \
        jq \
        unzip \
        wget \
 && rm -rf /var/lib/apt/lists/*

# Use Bash as default shell so ASDF-VM can work
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG asdf_version

# Ref: http://asdf-vm.com/manage/configuration.html#environment-variables
ENV ASDF_DIR="/opt/asdf-vm" \
    ASDF_DATA_DIR="/opt/asdf-vm" \
    ASDF_REPOSITORY=https://github.com/asdf-vm/asdf \
    ASDF_VERSION=${asdf_version}

ENV PATH ${ASDF_DIR}/bin:${ASDF_DATA_DIR}/shims:$PATH

RUN set -ex \
 && git clone \
        -c advice.detachedHead=false \
        --depth 1 \
        --branch "v$ASDF_VERSION" \
        "$ASDF_REPOSITORY" \
        "$ASDF_DIR" \
 && touch "${ASDF_DIR}/asdf_updates_disabled" \
 && asdf --version

COPY scripts/install-asdf-tools.sh /usr/local/bin/install-asdf-tools

CMD ["bash"]
