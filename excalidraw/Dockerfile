# Note: this Dockerfile is highly based on https://github.com/excalidraw/excalidraw/blob/master/Dockerfile

FROM node:18-alpine AS build

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

ARG excalidraw_version

# hadolint ignore=DL3047
RUN set -ex \
 && wget -O - \
        "https://github.com/excalidraw/excalidraw/archive/refs/tags/v${excalidraw_version}.tar.gz" \
        | tar -xz -f - \
 && mv -v "excalidraw-${excalidraw_version}" /opt/node_app

WORKDIR /opt/node_app

RUN yarn --ignore-optional --network-timeout 600000

ARG NODE_ENV=production

RUN yarn build:app:docker


FROM nginx:stable-alpine

COPY --from=build /opt/node_app/build /usr/share/nginx/html

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
