ARG caddy_tag=undefined

FROM caddy:${caddy_tag} AS caddy-base

FROM alpine:3.24 AS rtproxy-base

ARG routatic_proxy_version=undefined

RUN set -ex \
 && DL_ARCH="amd64" \
 && if [ "$( arch )" = "aarch64" ] ; then DL_ARCH="arm64" ; fi \
 && wget -q -O /routatic-proxy \
        "https://github.com/routatic/proxy/releases/download/v${routatic_proxy_version}/routatic-proxy_linux-${DL_ARCH}" \
 && wget -q -O /config.example.json \
        "https://raw.githubusercontent.com/routatic/proxy/refs/tags/v${routatic_proxy_version}/configs/config.example.json"

FROM alpine:3.24

ARG s6_overlay_version=3.2.3.2

# hadolint ignore=DL4006
RUN set -ex \
 && DL_ARCH="$( arch )" \
 && wget -q -O - "https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-noarch.tar.xz" \
        | tar -C / -Jxp -f - \
 && wget -q -O - "https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-${DL_ARCH}.tar.xz" \
        | tar -C / -Jxp -f -

RUN set -ex \
 && apk add --no-cache \
        ca-certificates \
        tzdata

RUN set -ex \
 && addgroup -g 700 rtproxy \
 && adduser -D -u 700 -G rtproxy rtproxy \
 && addgroup -g 800 caddy \
 && adduser -D -u 800 -G caddy caddy

COPY --from=caddy-base --chown=root:root --chmod=0755 /usr/bin/caddy /bin/caddy
COPY --from=rtproxy-base --chown=root:root --chmod=0755 /routatic-proxy /bin/routatic-proxy

COPY s6-overlay/ /etc/s6-overlay/

COPY --from=rtproxy-base --chown=rtproxy:rtproxy --chmod=u=rwX,go= /config.example.json /etc/routatic-proxy/config.json
COPY --chown=root:caddy --chmod=u=rwX,g=rX,o= Caddyfile /etc/caddy/Caddyfile

ENV ROUTATIC_PROXY_CONFIG="/etc/routatic-proxy/config.json" \
    ROUTATIC_PROXY_HOST="127.0.0.1" \
    ROUTATIC_PROXY_PORT="3456"

ENV CADDY_PORT="8000" \
    CADDY_LOG_LEVEL="info" \
    CADDY_LOG_FORMAT="json"

# Ref: https://code.claude.com/docs/en/authentication#authentication-precedence
ENV CADDY_PROXY_HEADER="X-Api-Key"

ENTRYPOINT ["/init"]
