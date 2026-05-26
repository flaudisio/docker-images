FROM alpine:3.23 AS builder

ARG go_crond_version
ARG lego_version

# hadolint ignore=DL4006
RUN set -ex \
 && DL_ARCH="amd64" \
 && if [ "$( arch )" = "aarch64" ] ; then DL_ARCH="arm64" ; fi \
 && wget -q -O go-crond "https://github.com/webdevops/go-crond/releases/download/${go_crond_version}/go-crond.linux.${DL_ARCH}" \
 && wget -q -O - "https://github.com/go-acme/lego/releases/download/v${lego_version}/lego_v${lego_version}_linux_${DL_ARCH}.tar.gz" \
        | tar -xz -f - lego

FROM python:3.13-alpine

COPY --from=builder --chown=root:root --chmod=0755 /go-crond /usr/bin/go-crond
COPY --from=builder --chown=root:root --chmod=0755 /lego /usr/bin/lego

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
    HOOK_CMD=/usr/bin/acme-oci-cert-updater

COPY acme-oci.sh /usr/bin/acme-oci
COPY acme-oci-cert-updater.sh $HOOK_CMD

COPY entrypoint.sh /usr/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

CMD ["acme-oci"]
