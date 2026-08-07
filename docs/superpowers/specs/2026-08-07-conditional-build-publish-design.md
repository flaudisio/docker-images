# Conditional Docker Image Build & Publish Workflow

Date: 2026-08-07

## Goal

A GitHub Actions workflow that builds only the Docker images whose directories
changed in a PR, and publishes those images to Docker Hub when merged to main.
Per-image README.md files are synced to Docker Hub as repository descriptions
when present.

## Triggers

```yaml
on:
  pull_request:
  push:
    branches: [main]
```

- Pull request: build-only (validates Docker builds succeed).
- Push to main: build + push to registry + README sync.

## Image directories

`acme-oci`, `autobrr`, `claude-proxy`, `excalidraw`, `hashibackup`,
`semaphore`, `transfer.sh`.

## Jobs

### `detect-changes`

- Runs on `ubuntu-latest`.
- Uses `tj-actions/changed-files@v46` to obtain changed file paths for both
  PR and push events.
- Filters paths against the known image directories.
- Outputs `images` as a JSON array (e.g. `["autobrr","excalidraw"]`).
- Empty array when no image directory changed; the matrix job then has no
  entries and is skipped.

### `build`

- `needs: detect-changes`, runs on `ubuntu-latest`.
- Matrix: `image: ${{ fromJSON(needs.detect-changes.outputs.images) }}`.
- Steps:
  1. `actions/checkout@v7`
  2. `docker/setup-qemu-action@v3` (arm64 emulation for multi-platform images)
  3. `docker/setup-buildx-action@v3`
  4. Main only: `docker/login-action@v3` using Docker Hub secrets
  5. `docker buildx bake --file <image>/docker-bake.hcl` (validate)
  6. Main only: `docker buildx bake --file <image>/docker-bake.hcl --push`
  7. Main only, if `<image>/README.md` exists:
     `peter-evans/dockerhub-description@v4` to sync the README to Docker Hub

## Secrets

| Secret              | Used on    |
| ------------------- | ---------- |
| `DOCKERHUB_USERNAME`| Main only  |
| `DOCKERHUB_TOKEN`   | Main only  |

## Out of scope

- No cache backends beyond buildx defaults.
- No artifact upload of PR test images.
- No `latest` tag; versioned tags only (from bake files).
- No multi-registry support (only `docker.io/flaudisio`).
- No notification/slack integration.
