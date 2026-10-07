# hashibackup

Scheduled backups of HashiCorp Consul and Nomad state: captures `consul snapshot` and
`nomad operator snapshot` files, optionally pruning old ones.

## Usage

```sh
docker run --rm \
  -e HB_PRODUCTS='consul nomad' \
  -e CONSUL_HTTP_ADDR=http://consul:8500 \
  -e NOMAD_ADDR=http://nomad:4646 \
  -v /backups:/var/hashibackup \
  flaudisio/hashibackup:0.3.1
```

Typically run from a scheduler. Arguments after `hashibackup` are forwarded to the script.

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| `HB_PRODUCTS` | _(empty)_ | Space-separated products to back up (`consul`, `nomad`). |
| `HB_CONFIG_FILE` | `/etc/hashibackup.env` | Sourced before defaults; overrides env vars. |
| `HB_DATA_DIR` | `/var/hashibackup` | Backup output directory. |
| `HB_ENABLE_RETENTION_POLICY` | `false` | Enable pruning of old backups (`true`/`yes`/`1`). |
| `HB_KEEP_LAST` | `60` | Number of newest backups to keep. |
| `CONSUL_HTTP_ADDR` | _(empty)_ | Consul address. |
| `CONSUL_HTTP_TOKEN` | _(empty)_ | Consul ACL token. |
| `NOMAD_ADDR` | _(empty)_ | Nomad address. |
| `NOMAD_TOKEN` | _(empty)_ | Nomad ACL token. |
| `DEBUG` | _(empty)_ | Enable debug logging. |

## Upstream images

- `ubuntu:24.04` — runtime base.
- `hashicorp/consul` — source of the `consul` binary.
- `hashicorp/nomad` — source of the `nomad` binary.
