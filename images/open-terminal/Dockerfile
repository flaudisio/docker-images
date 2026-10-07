ARG open_terminal_tag=undefined

FROM ghcr.io/open-webui/open-terminal:${open_terminal_tag}

RUN set -ex \
 && apt-get update \
 && apt-get install -q -y --no-install-recommends \
        dos2unix \
        moreutils \
        mtr-tiny \
        net-tools \
        openssh-client \
        patch \
        ripgrep \
        sqlite3 \
        sshpass \
        tree \
        tzdata \
        unzip \
        whois \
 && rm -rf /var/lib/apt/lists/*

# hadolint ignore=DL4006
RUN set -ex \
 && curl -fsSL https://mise.run | MISE_INSTALL_PATH="/usr/bin/mise" sh

# Ref: https://mise.jdx.dev/dev-tools/shims.html#path-activation
ENV PATH="/home/user/.local/share/mise/shims:${PATH}"
