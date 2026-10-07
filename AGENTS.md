# AGENTS.md

Collection of independent Docker images, one directory per image under `images/`, published
to Docker Hub (`docker.io/flaudisio`).

## Build & publish

- Build from inside an image directory — the shared override auto-loads via a relative symlink:
  `cd images/<name> && docker buildx bake` (add `--push` to publish).
- CI (`.github/workflows/build-publish.yml`) builds only images whose `images/<name>/**`
  changed: PR = build only, push to `main` = build + push. New directories under `images/`
  are auto-detected; no workflow edit needed.
- Editing the root `docker-bake.override.hcl` alone triggers no rebuild (change detection is
  scoped to `images/**`).
- Only versioned tags are published (from each `docker-bake.hcl`); never `latest`.

## Adding or editing an image

- Files: `images/<name>/Dockerfile` + `docker-bake.hcl`, plus `docker-bake.override.hcl`
  which MUST be a symlink, not a copy:
  `ln -s ../../docker-bake.override.hcl images/<name>/docker-bake.override.hcl`
- `docker-bake.hcl` defines a `default` target with `inherits = ["_template"]`, pins the
  upstream version in a variable (`<name>_version`, or e.g. `autobrr_tag`), and sets
  `tags = formatlist("%s/<name>:%s", registries, ...)`.
- Shared config (registries, `_template` labels, base platforms) lives only in the root
  override. Most images re-declare `platforms` to add `linux/arm64`.
- Each image needs a `README.md` (not enforced by CI) with these sections in order: title,
  short description, `## Usage`, `## Environment variables`, `## Upstream images`. Copy an
  existing README as the template; list only upstream images whose content ships (name any
  build-stage-only image in prose).
- Directory name and Docker Hub repo can differ: `claude-proxy` publishes to
  `flaudisio/claudeproxy`.
- `semaphore` is special: `Dockerfile.base` is a `cacheonly` target reused via `contexts`,
  and it publishes two repos (`semaphore-server`, `semaphore-runner`).

## Version bumps

- Bump the version variable default in `images/<name>/docker-bake.hcl`; commit as
  `chore(<name>): bump to <version>` (conventional commits, per repo history).

## Lint / verify

- `mise run pre-commit` (= `pre-commit run --all-files`), or scope with
  `pre-commit run --files <paths>`.
- Hooks: yamllint `--strict` (line length 140), hadolint (`.hadolint.yaml`), shellcheck,
  terragrunt HCL fmt. Tools are provisioned by mise (`mise install`).
- `mise run fmt` formats HCL.
- Markdown wraps at 100 chars (`.editorconfig`).
