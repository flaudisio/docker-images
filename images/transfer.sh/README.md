# transfer.sh

[transfer.sh](https://github.com/dutchcoders/transfer.sh) file-sharing service with an entrypoint
that fixes volume permissions and drops to a non-root user.

## Usage

```sh
docker run --rm -p 8080:8080 \
  -v transfer-data:/data \
  -v transfer-temp:/temp \
  flaudisio/transfer.sh:1.6.1-2
```

transfer.sh's own flags can be appended after `transfer`:

```sh
docker run --rm -p 8080:8080 ... flaudisio/transfer.sh:1.6.1-2 transfer --provider local
```

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| `TRANSFER_USER` | `transfer` | User the service runs as. |
| `BASEDIR` | `/data` | Storage directory for uploaded files. |
| `TEMP_PATH` | `/temp` | Temporary upload directory. |

## Upstream images

- `alpine:3.24` — runtime base.

`gosu`, `tini`, and `transfer.sh` are downloaded from GitHub releases, not images.
