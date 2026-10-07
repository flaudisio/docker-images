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

# ---------------------------------------------------------------------------
# Expose GET /skills/{name} alongside the upstream GET /skills/read?name=...
#
# Open WebUI 0.11.4 loads terminal skill content from GET /skills/<name>, but
# Open Terminal 0.14.0 only serves GET /skills/read?name=<name>. The backend
# gets a 404 and view_skill answers:
#   {"error": "Skill 'terminal:<name>' not found"}
# The list (GET /skills) works, which is why the $ picker shows the skills but
# they never load.
#
# Upstream fixed this on the Open WebUI side (open-webui#30423) by switching to
# /skills/read, but that is not in a released version yet. This patch makes the
# terminal accept both routes, so it keeps working after Open WebUI is updated.
#
# Drop this block once a released Open Terminal serves /skills/{name} itself.
# ---------------------------------------------------------------------------
COPY skills-endpoint.patch /tmp/skills-endpoint.patch

RUN set -ex \
 && purelib="$(python -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')" \
 && if ! grep -F -q '"/skills/{name}"' "$purelib/open_terminal/main.py"; then \
        patch -p1 --no-backup-if-mismatch -d "$purelib" < /tmp/skills-endpoint.patch; \
        grep -q '"/skills/{name}"' "$purelib/open_terminal/main.py"; \
        python -c "import ast, sys; ast.parse(open(sys.argv[1]).read())" \
            "$purelib/open_terminal/main.py"; \
        echo "GET /skills/{name} added"; \
    fi \
 && rm -f /tmp/skills-endpoint.patch
