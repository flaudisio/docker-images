FROM alpine:3.19 AS builder

ARG go_crond_version
ARG lego_version

# hadolint ignore=DL4006
RUN set -ex \
 && apk add --no-cache \
        ca-certificates \
        curl \
 && DL_ARCH="amd64" \
 && if [ "$( arch )" = "aarch64" ] ; then DL_ARCH="arm64" ; fi \
 && curl -fL -o go-crond "https://github.com/webdevops/go-crond/releases/download/${go_crond_version}/go-crond.linux.${DL_ARCH}" \
 && chmod -v 755 go-crond \
 && curl -fL "https://github.com/go-acme/lego/releases/download/v${lego_version}/lego_v${lego_version}_linux_${DL_ARCH}.tar.gz" \
        | tar -xz -f - lego \
 && chmod -v 755 lego

FROM python:3.11-alpine

COPY --from=builder --chown=root:root /go-crond /usr/local/bin/go-crond
COPY --from=builder --chown=root:root /lego /usr/local/bin/lego

ARG oci_cli_version

RUN set -ex \
 && apk add --no-cache \
        bash \
        jq \
 && apk add --no-cache --virtual .build-deps \
        gcc \
        libffi-dev \
        musl-dev \
 && pip install --no-cache-dir \
        "oci-cli==${oci_cli_version}" \
 && apk del --no-cache --purge .build-deps \
 && find /usr/local -depth -type d -name '__pycache__' -exec rm -rf '{}' \; \
 && rm -rf ~/.cache

ENV CRON_SCHEDULE="0 */12 * * *" \
    HOOK_CMD=/usr/local/bin/acme-oci-cert-updater

COPY acme-oci.sh /usr/local/bin/acme-oci
COPY acme-oci-cert-updater.sh $HOOK_CMD

COPY entrypoint.sh /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["acme-oci"]
