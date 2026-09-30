# Based on https://github.com/excalidraw/excalidraw/blob/4872083/Dockerfile

FROM --platform=${BUILDPLATFORM} alpine:3 AS build

ARG keeweb_version

WORKDIR /html

# hadolint ignore=DL3047
RUN set -ex \
 && wget -q -O /tmp/keeweb-html.zip \
        "https://github.com/keeweb/keeweb/releases/download/v${keeweb_version}/KeeWeb-${keeweb_version}.html.zip" \
 && unzip -q /tmp/keeweb-html.zip


FROM caddy:2-alpine

RUN set -ex \
 && apk add --no-cache \
        tzdata

COPY --from=build /html /var/www

ENV CADDY_PORT="80" \
    CADDY_LOG_LEVEL="info" \
    CADDY_LOG_FORMAT="json"

COPY Caddyfile /etc/caddy/Caddyfile

HEALTHCHECK CMD wget -q -O /dev/null http://localhost/-/health || exit 1
