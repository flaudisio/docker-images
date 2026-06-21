# Based on https://github.com/excalidraw/excalidraw/blob/c08be696/Dockerfile

FROM --platform=${BUILDPLATFORM} node:24 AS build

ARG excalidraw_version

# hadolint ignore=DL3047
RUN set -ex \
 && wget -q -O excalidraw.tar.gz \
        "https://github.com/excalidraw/excalidraw/archive/${excalidraw_version}.tar.gz" \
 && tar -xz -f excalidraw.tar.gz \
 && mv excalidraw-* /opt/node_app

WORKDIR /opt/node_app

RUN --mount=type=cache,target=/root/.cache/yarn \
    npm_config_target_arch=${TARGETARCH} yarn --frozen-lockfile --network-timeout 600000

ARG NODE_ENV=production

RUN npm_config_target_arch=${TARGETARCH} yarn build:app:docker


FROM caddy:2-alpine

COPY --from=build /opt/node_app/excalidraw-app/build /var/www

ENV CADDY_PORT="80" \
    CADDY_LOG_LEVEL="info" \
    CADDY_LOG_FORMAT="json"

COPY Caddyfile /etc/caddy/Caddyfile

HEALTHCHECK CMD wget -q -O /dev/null http://localhost/-/health || exit 1
