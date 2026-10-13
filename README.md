# Docker Images

Collection of Docker images published to [Docker Hub](https://hub.docker.com/u/flaudisio)
as `flaudisio/<name>`. Each image lives in its own directory under `images/`, with a
dedicated README covering configuration and environment variables. Only versioned tags are
published — never `latest`.

## Images

| Image | Description |
| --- | --- |
| [acme-oci](images/acme-oci) | Let's Encrypt certs via lego, imported into OCI Certificates |
| [autobrr](images/autobrr) | autobrr with a qBittorrent free-disk-space checker |
| [claude-proxy](images/claude-proxy) | API-key-guarded Caddy reverse proxy |
| [excalidraw](images/excalidraw) | Excalidraw web app served as static files via Caddy |
| [hashibackup](images/hashibackup) | Scheduled Consul and Nomad state snapshots |
| [keeweb](images/keeweb) | KeeWeb web app served as static files via Caddy |
| [open-terminal](images/open-terminal) | Open Terminal slim image with extra CLI tools and mise |
| [semaphore](images/semaphore) | Semaphore UI control plane plus Ansible task runner |
| [transfer.sh](images/transfer.sh) | transfer.sh file-sharing service |

The Docker Hub repo name usually matches the directory. Exceptions:
`claude-proxy` publishes as `flaudisio/claudeproxy`, and `semaphore` publishes
`flaudisio/semaphore-server` and `flaudisio/semaphore-runner`.

## Usage

```sh
docker pull flaudisio/<name>:<version>
```

Refer to each image's own README under `images/` for environment variables and usage.

## Building

Build from inside an image directory with `docker buildx bake` (add `--push` to publish). See
[AGENTS.md](AGENTS.md) for the full build and publishing workflow.

## License

[MIT](LICENSE).
