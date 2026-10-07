# excalidraw

Serves the [Excalidraw](https://github.com/excalidraw/excalidraw) web app as static files via
Caddy.

## Usage

```sh
docker run --rm -p 8080:80 flaudisio/excalidraw:4872083
```

Open <http://localhost:8080>. Health endpoint at `GET /-/health`.

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| `CADDY_PORT` | `80` | Port Caddy listens on. |
| `CADDY_LOG_LEVEL` | `info` | Caddy log level. |
| `CADDY_LOG_FORMAT` | `json` | Caddy log format. |
| `CADDY_LOG_FORMAT_LEVEL_FORMAT` | `upper` | Log level casing in the log format. |

## Upstream images

- `caddy:2-alpine` — runtime base and web server.

The app is built from the Excalidraw source tarball; `node:24` is build-stage only.
