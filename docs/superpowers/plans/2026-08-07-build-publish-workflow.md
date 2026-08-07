# Conditional Image Build & Publish Workflow — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a GitHub Actions workflow that builds only the Docker images whose
directories changed in a PR, and publishes them to Docker Hub when merged to main.

**Architecture:** A `detect-changes` job uses `tj-actions/changed-files` to list
changed files restricted to the seven image directories, reduces them to a unique
JSON array of directory names, and feeds that array into a `build` matrix job. The
build job runs `docker buildx bake` (the repo's existing local build command, run
from inside each image directory) per image; the `--push` flag and Docker Hub login
are gated on `github.ref == 'refs/heads/main'`. A final step syncs each image's
`README.md` to Docker Hub when present.

**Tech Stack:** GitHub Actions, Docker Buildx Bake, `tj-actions/changed-files@v46`,
`peter-evans/dockerhub-description@v4`.

## Global Constraints

- Image directories: `acme-oci`, `autobrr`, `claude-proxy`, `excalidraw`,
  `hashibackup`, `semaphore`, `transfer.sh`.
- Use the same build command the repo uses locally: `cd <image> && docker buildx
  bake` (override files auto-load from the working directory).
- Publish only the versioned tags produced by each `docker-bake.hcl` — no `latest`.
- Registry: `docker.io/flaudisio` (from `docker-bake.override.hcl` defaults).
- Secrets: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` (Docker Hub login, main only).
- `semaphore` publishes to `semaphore-server` and `semaphore-runner` (two repos),
  so its README sync is skipped.
- YAML must pass yamllint (`.yamllint.yaml`, line length 140) via pre-commit.
- Commit style: conventional commits (see repo history).

---

### Task 1: Add the build & publish workflow

**Files:**
- Create: `.github/workflows/build-publish.yml`

**Interfaces:**
- Consumes: nothing.
- Produces: the workflow file only. No other task depends on it.

- [ ] **Step 1: Create the workflow file**

Create `.github/workflows/build-publish.yml` with exactly this content:

```yaml
---
name: Build & Publish

# yamllint disable-line rule:truthy
on:
  pull_request:
  push:
    branches: [main]

permissions:
  contents: read

jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      images: ${{ steps.images.outputs.images }}
    steps:
      - uses: actions/checkout@v7
        with:
          fetch-depth: 0
      - name: Detect changed image files
        id: changed
        uses: tj-actions/changed-files@v46
        with:
          files: |
            acme-oci/**
            autobrr/**
            claude-proxy/**
            excalidraw/**
            hashibackup/**
            semaphore/**
            transfer.sh/**
      - name: Compute changed image directories
        id: images
        run: |
          images=$(jq -r '.[]' <<< '${{ steps.changed.outputs.all_changed_files }}' \
            | cut -d/ -f1 | sort -u | jq -R -s -c 'split("\n")[:-1]')
          echo "images=${images}" >> "$GITHUB_OUTPUT"

  build:
    needs: detect-changes
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        image: ${{ fromJSON(needs.detect-changes.outputs.images) }}
    steps:
      - uses: actions/checkout@v7
      - uses: docker/setup-qemu-action@v3
      - uses: docker/setup-buildx-action@v3
      - name: Log in to Docker Hub
        if: github.ref == 'refs/heads/main'
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      - name: Build
        run: |
          cd "${{ matrix.image }}"
          docker buildx bake
      - name: Push
        if: github.ref == 'refs/heads/main'
        run: |
          cd "${{ matrix.image }}"
          docker buildx bake --push
      - name: Sync README to Docker Hub
        if: >-
          github.ref == 'refs/heads/main'
          && matrix.image != 'semaphore'
          && hashFiles(format('{0}/README.md', matrix.image)) != ''
        uses: peter-evans/dockerhub-description@v4
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
          repository: flaudisio/${{ matrix.image }}
          readme-filepath: ${{ matrix.image }}/README.md
```

- [ ] **Step 2: Validate the YAML**

Run: `yamllint --strict .github/workflows/build-publish.yml`
Expected: no output (passes).

- [ ] **Step 3: Run pre-commit on the file**

Run: `pre-commit run --files .github/workflows/build-publish.yml`
Expected: all hooks pass; no files modified by the fixers.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/build-publish.yml
git commit -m "feat(ci): build and publish only images changed in PR"
```

## Behavior notes

- **Empty matrix:** when no image directory changed, `detect-changes` outputs `[]`,
  and GitHub Actions skips the `build` job (empty matrix).
- **Change detection:** `tj-actions/changed-files` computes the diff base
  automatically for both `pull_request` and `push` events, so no bash branching on
  event type is needed.
- **Multi-arch:** bake reads `platforms` from each `docker-bake.hcl`;
  `setup-qemu-action` enables arm64 emulation on the amd64 runner.
- **README sync:** gated on the file existing (`hashFiles(...) != ''`) so images
  without a `README.md` are skipped until one is added. `semaphore` is excluded
  because it maps to two Docker Hub repos.
- **Verification in CI:** builds are exercised on PRs (build only); the same
  command with `--push` runs on main.
