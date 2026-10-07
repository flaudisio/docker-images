# autobrr

[autobrr](https://autobrr.com) with an extra `qbt-sizechecker` helper that verifies a remote
qBittorrent instance has enough free disk space before a download starts.

## Usage

Runs autobrr's entrypoint unchanged; configure it with its own environment variables and config
file (see the [autobrr docs](https://autobrr.com)). Run `qbt-sizechecker` from an autobrr
exec/filter when you need the check:

```sh
docker run --rm flaudisio/autobrr:v1.87.0 qbt-sizechecker
```

Exit code `0` means enough space; `1` means not enough, or the server was unreachable.

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| `SC_QBITTORRENT_BASE_URL` | _(empty)_ | qBittorrent base URL, including scheme and port. |
| `SC_QBITTORRENT_API_KEY` | _(empty)_ | qBittorrent API key, sent as a bearer token. |
| `SC_REQUIRED_SPACE` | `5368709120` | Minimum free space in bytes; also the first argument. |

autobrr's own settings come from its upstream image; see the autobrr documentation.

## Upstream images

- `ghcr.io/autobrr/autobrr` — the autobrr application.
