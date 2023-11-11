FROM alpine:3.18 AS builder

ARG go_crond_version

RUN set -ex \
 && apk add --no-cache \
        ca-certificates \
        curl \
 && DL_ARCH=amd64 \
 && if [ "$( arch )" = "aarch64" ] ; then DL_ARCH=arm64 ; fi \
 && curl -fL -o /usr/local/bin/go-crond "https://github.com/webdevops/go-crond/releases/download/${go_crond_version}/go-crond.linux.${DL_ARCH}" \
 && chmod -v 755 /usr/local/bin/go-crond

FROM python:3.11-alpine

COPY --from=builder /usr/local/bin/go-crond /usr/local/bin/go-crond

ENV SCHEDULE "0 */12 * * *"

ARG certbot_dns_cloudflare_version
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
        "certbot-dns-cloudflare==${certbot_dns_cloudflare_version}" \
        "oci-cli==${oci_cli_version}" \
 && apk del --no-cache --purge .build-deps \
 && find /usr/local -depth -type d -name '__pycache__' -exec rm -rf '{}' \; \
 && rm -rf ~/.cache

COPY certbot-oci.sh /usr/local/bin/certbot-oci
COPY entrypoint.sh /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["certbot-oci"]
