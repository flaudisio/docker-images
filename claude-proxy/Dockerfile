ARG caddy_tag=undefined
ARG routatic_proxy_tag=undefined

FROM caddy:${caddy_tag} AS caddy-base
FROM ghcr.io/routatic/proxy:${routatic_proxy_tag} AS rtproxy-base

FROM alpine:3.23

ARG S6_OVERLAY_VERSION=3.2.3.2

# hadolint ignore=DL4006
RUN set -ex \
 && DL_ARCH="$( arch )" \
 && wget -q -O - "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
        | tar -C / -Jxp -f - \
 && wget -q -O - "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${DL_ARCH}.tar.xz" \
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
COPY --from=rtproxy-base --chown=root:root --chmod=0755 /usr/local/bin/routatic-proxy /bin/routatic-proxy
COPY --from=rtproxy-base --chown=rtproxy:rtproxy --chmod=u=rwX,go= /etc/routatic-proxy/config.json /etc/routatic-proxy/config.json

COPY s6-overlay/ /etc/s6-overlay/

COPY --chown=root:caddy --chmod=u=rwX,g=rX,o= Caddyfile /etc/caddy/Caddyfile

ENV CADDY_PORT="8000" \
    CADDY_LOG_LEVEL="info" \
    CADDY_LOG_FORMAT="json" \
    CADDY_PROXY_HEADER="X-ClaudeProxy-Token"

ENV ROUTATIC_PROXY_CONFIG=/etc/routatic-proxy/config.json \
    ROUTATIC_PROXY_HOST=127.0.0.1 \
    ROUTATIC_PROXY_PORT=3456

ENTRYPOINT ["/init"]
