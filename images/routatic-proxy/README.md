# routatic-proxy

Additional authorization layer in front of [routatic-proxy](https://github.com/routatic/proxy):
a Caddy reverse proxy guarded by an API-key header, running alongside it under s6-overlay.
Requests presenting the expected header are proxied; everything else gets a 401.

## Usage

```sh
docker run --rm -p 8000:8000 \
  -e ROUTATIC_PROXY_API_KEY=secret \
  -e CADDY_PROXY_TOKEN=secret \
  flaudisio/routatic-proxy:latest
```

Health endpoint at `GET /health`. `ROUTATIC_PROXY_API_KEY` is required; `CADDY_PROXY_TOKEN` is the
optional client key clients must present. Configure `routatic-proxy` through its config file or
environment.

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| `CADDY_PROXY_TOKEN` | `ROUTATIC_PROXY_API_KEY` | Optional client key; masks the routatic key. |
| `CADDY_PROXY_HEADER` | `X-Api-Key` | Header name the client must send. |
| `CADDY_PORT` | `8000` | Port Caddy listens on. |
| `CADDY_LOG_LEVEL` | `info` | Caddy log level. |
| `CADDY_LOG_FORMAT` | `json` | Caddy log format. |
| `CADDY_LOG_FORMAT_LEVEL_FORMAT` | `upper` | Log level casing in the log format. |
| `ROUTATIC_PROXY_CONFIG` | `/etc/routatic-proxy/config.json` | routatic-proxy config path. |
| `ROUTATIC_PROXY_HOST` | `127.0.0.1` | routatic-proxy bind host. |
| `ROUTATIC_PROXY_PORT` | `3456` | routatic-proxy bind port. |
| `ROUTATIC_PROXY_API_KEY` | _required_ | OpenCode Go API key. |

`ROUTATIC_PROXY_API_KEY` is the OpenCode Go API key and is required. `CADDY_PROXY_TOKEN` is an
optional client key that defaults to it: set it to mask the routatic key, or to keep that key
unchanged when the client key must change. Other upstream routatic-proxy environment variables can
also be set; see the upstream
[env vars](https://github.com/routatic/proxy/blob/main/CONFIGURATION.md#environment-variables).

## Upstream images

- `caddy` — the Caddy binary.
- `alpine:3.24` — runtime base.

`routatic-proxy` and `s6-overlay` are installed from GitHub release artifacts, not images.
