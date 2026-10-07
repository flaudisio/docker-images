# semaphore

[Semaphore UI](https://semaphoreui.com) as two images: `semaphore-server` (control plane) and
`semaphore-runner` (Ansible-based task runner). Both share a base with `gosu` and `tini` for
privilege dropping.

## Usage

```sh
docker run -d -p 3000:3000 \
  -e SEMAPHORE_ADMIN=admin \
  -e SEMAPHORE_ADMIN_NAME=Admin \
  -e SEMAPHORE_ADMIN_EMAIL=admin@example.com \
  -e SEMAPHORE_ADMIN_PASSWORD=secret \
  -v semaphore:/etc/semaphore \
  flaudisio/semaphore-server:2.19.12
```

```sh
docker run -d \
  -e SEMAPHORE_RUNNER_REGISTRATION_TOKEN=... \
  -v semaphore:/etc/semaphore \
  flaudisio/semaphore-runner:2.19.12-ansible-2.20
```

The runner registers itself when `SEMAPHORE_RUNNER_REGISTRATION_TOKEN` is set, then must still be
enabled in the Semaphore UI.

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| `CONFIG_DIR` | `/etc/semaphore` | Semaphore config/state directory. |
| `SEMAPHORE_TMP_PATH` | `/tmp/semaphore` | Temporary working directory. |
| `SEMAPHORE_CLI_EXTRA_ARGS` | _(empty)_ | Extra arguments appended to the CLI command. |
| `SEMAPHORE_ADMIN` | _(empty)_ | Admin login; when set, the user is created/updated. |
| `SEMAPHORE_ADMIN_NAME` | _(empty)_ | Admin display name. |
| `SEMAPHORE_ADMIN_EMAIL` | _(empty)_ | Admin email. |
| `SEMAPHORE_ADMIN_PASSWORD` | _(empty)_ | Admin password. |
| `SEMAPHORE_RUNNER_REGISTRATION_TOKEN` | _(empty)_ | Token used to register the runner. |
| `SEMAPHORE_RUNNER_TOKEN_FILE` | `$CONFIG_DIR/runner.token` | Registered runner token file. |
| `SEMAPHORE_RUNNER_PRIVATE_KEY_FILE` | `$CONFIG_DIR/runner.key` | Registered runner key file. |
| `SEMAPHORE_WEB_ROOT` | _(empty)_ | Web root used in the post-registration hint. |
| `SSH_LOG_LEVEL` | `ERROR` | SSH client log level (runner only). |

Semaphore's own configuration variables and config file also apply; see the Semaphore docs.

## Upstream images

- `alpine:3.24` — runtime base for `semaphore-server`.
- `python:3.13-slim` — runtime base for `semaphore-runner`.

The `semaphore` binary, `gosu`, and `tini` are downloaded from GitHub releases, not images.
