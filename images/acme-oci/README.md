# acme-oci

Obtains and renews Let's Encrypt certificates with [lego](https://github.com/go-acme/lego)
(DNS-01 via Cloudflare), backs the lego state up to an OCI Object Storage bucket, and imports the
issued certificate into OCI Certificates.

## Usage

Run once, or with `--cron` to schedule via go-crond:

```sh
docker run --rm \
  -e CERT_DOMAINS=example.com,www.example.com \
  -e CERT_EMAIL=admin@example.com \
  -e CLOUDFLARE_DNS_API_TOKEN=... \
  -e OCI_CERT_BASENAME=example \
  -e OCI_BACKUP_BUCKET_NAME=my-bucket \
  -e OCI_COMPARTMENT_ID=ocid1.compartment.oc1..xxx \
  flaudisio/acme-oci:0.3.1 --cron
```

OCI CLI credentials must be available (a config file mounted at `~/.oci/config`, or `OCI_CLI_*`
environment variables). The hook imports the certificate into OCI Certificates unless
`DISABLE_HOOK_CMD` is set.

## Environment variables

Core:

| Variable | Default | Description |
| --- | --- | --- |
| `CERT_DOMAINS` | _required_ | Comma-separated domains; the first is the lego identifier. |
| `CERT_EMAIL` | _required_ | ACME account email. |
| `CLOUDFLARE_DNS_API_TOKEN` | _required_ | Cloudflare API token for DNS-01. |
| `OCI_CERT_BASENAME` | _required_ | Base name for the OCI certificate. |
| `OCI_BACKUP_BUCKET_NAME` | _required_ | OCI Object Storage bucket for lego state. |
| `CERT_STAGING` | _(empty)_ | Any non-empty value uses Let's Encrypt staging. |
| `DATA_DIR` | `lego-data` | lego working directory. |
| `HOOK_CMD` | `/usr/bin/acme-oci-cert-updater` | Hook run after issuance. |
| `DISABLE_BACKUP_BUCKET` | _(empty)_ | Skip bucket download/upload. |
| `DISABLE_HOOK_CMD` | _(empty)_ | Skip the certificate hook. |
| `CRON_SCHEDULE` | `0 */12 * * *` | Schedule used with `--cron`. |
| `DEBUG` | _(empty)_ | Enable debug logging. |

OCI certificate import (used by the hook):

| Variable | Default | Description |
| --- | --- | --- |
| `OCI_COMPARTMENT_ID` | _required_ | OCI compartment for the certificate. |
| `OCI_TAG_COMPONENT_REPO` | `UNDEFINED` | Defined tag `iac.component-repo`. |
| `OCI_TAG_COMPONENT_PATH` | `UNDEFINED` | Defined tag `iac.component-path`. |
| `OCI_TAG_CREATED_BY` | `acme-oci-cert-updater` | Defined tag `iac.created-by`. |
| `OCI_TAG_ENVIRONMENT` | `UNDEFINED` | Defined tag `iac.environment`. |
| `OCI_TAG_OWNER` | `UNDEFINED` | Defined tag `iac.owner`. |
| `OCI_TAG_SERVICE_NAME` | `acme-oci-cert-updater` | Defined tag `iac.service-name`. |
| `SKIP_OCI_CERT_CREATION` | _(empty)_ | Skip creating the OCI certificate. |
| `SKIP_OCI_CERT_UPDATE` | _(empty)_ | Skip updating the OCI certificate. |

## Upstream images

- `python:3.13-alpine` — runtime base.

`lego` and `go-crond` are downloaded from GitHub releases, not images.
