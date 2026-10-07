# claude-proxy

Caddy reverse proxy guarded by an API-key header, running alongside `routatic-proxy` under
s6-overlay. Requests presenting the expected header are proxied; everything else gets a 401.

## Usage

```sh
docker run --rm -p 8000:8000 -e CADDY_PROXY_TOKEN=secret flaudisio/claudeproxy:0.3.1
```

Health endpoint at `GET /health`. Configure `routatic-proxy` through its config file or
environment.

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| `CADDY_PROXY_TOKEN` | `ROUTATIC_PROXY_API_KEY` | Value the guard header must match. |
| `CADDY_PROXY_HEADER` | `X-Api-Key` | Header name the client must send. |
| `CADDY_PORT` | `8000` | Port Caddy listens on. |
| `CADDY_LOG_LEVEL` | `info` | Caddy log level. |
| `CADDY_LOG_FORMAT` | `json` | Caddy log format. |
| `CADDY_LOG_FORMAT_LEVEL_FORMAT` | `upper` | Log level casing in the log format. |
| `ROUTATIC_PROXY_CONFIG` | `/etc/routatic-proxy/config.json` | routatic-proxy config path. |
| `ROUTATIC_PROXY_HOST` | `127.0.0.1` | routatic-proxy bind host. |
| `ROUTATIC_PROXY_PORT` | `3456` | routatic-proxy bind port. |
| `ROUTATIC_PROXY_API_KEY` | _(empty)_ | Fallback value for `CADDY_PROXY_TOKEN`. |

## Upstream images

- `caddy` — the Caddy binary.
- `alpine:3.24` — runtime base.

`routatic-proxy` and `s6-overlay` are installed from GitHub release artifacts, not images.
