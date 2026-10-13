ARG open_terminal_tag=undefined

FROM ghcr.io/open-webui/open-terminal:${open_terminal_tag}

RUN set -ex \
 && apt-get update \
 && apt-get install -q -y --no-install-recommends \
        bzip2 \
        dnsutils \
        dos2unix \
        file \
        fonts-liberation \
        iproute2 \
        iputils-ping \
        lsof \
        moreutils \
        mtr-tiny \
        netcat-openbsd \
        openssh-client \
        patch \
        ripgrep \
        rsync \
        sqlite3 \
        sshpass \
        strace \
        tesseract-ocr \
        tesseract-ocr-eng \
        tesseract-ocr-por \
        tree \
        tzdata \
        unzip \
        whois \
        xz-utils \
        zip \
        zstd \
 && rm -rf /var/lib/apt/lists/*

ARG mise_version=""

# hadolint ignore=DL4006
RUN set -ex \
 && curl -fsSL https://mise.run | MISE_VERSION="$mise_version" MISE_INSTALL_PATH="/usr/bin/mise" sh

# https://mise.jdx.dev/directories.html#directories
ENV MISE_CACHE_DIR="/mise/cache" \
    MISE_DATA_DIR="/mise/data" \
    MISE_STATE_DIR="/mise/state"

RUN set -ex \
 && mkdir -p "$MISE_CACHE_DIR" "$MISE_DATA_DIR" "$MISE_STATE_DIR" \
 && chown -R user:user "$MISE_CACHE_DIR" "$MISE_DATA_DIR" "$MISE_STATE_DIR"

# https://mise.jdx.dev/dev-tools/shims.html#path-activation
ENV PATH="${MISE_DATA_DIR}/shims:${PATH}"
