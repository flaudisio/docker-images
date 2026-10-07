# open-terminal

[Open Terminal](https://github.com/open-webui/open-terminal) slim image with `git` and `patch`
added.

## Usage

```sh
docker run --rm -p 8000:8000 -e OPEN_TERMINAL_API_KEY=secret flaudisio/open-terminal:0.14.0-slim
```

Open <http://localhost:8000>. See the upstream README for the full API.

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| `OPEN_TERMINAL_API_KEY` | auto-generated | API key; if unset, read it from the container logs. |

The slim variant ignores `OPEN_TERMINAL_PACKAGES` and `OPEN_TERMINAL_PIP_PACKAGES`; all other
settings are upstream. See the upstream README.

## Upstream images

- `ghcr.io/open-webui/open-terminal:0.14.0-slim` — the Open Terminal application.
