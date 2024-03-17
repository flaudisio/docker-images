# ASDF-VM

Image to install tools using [ASDF-VM](https://asdf-vm.com/).

## Usage

This image comes with the `install-asdf-tools` script, which automatically install all tools described in the `.tool-versions`
file present in the current directory.

### GitLab CI

Example job for [`.gitlab-ci.yml`](https://docs.gitlab.com/ee/ci/yaml/):

```yaml
Lint:
  stage: test
  image: flaudisio/asdf-alpine:3.19
  before_script:
    - install-asdf-tools
    - terraform --version
    - tflint --version
  script:
    - terraform fmt -recursive -check .
    - tflint .
```

## Flavors (drop-in replacements)

There are several flavors built by this repository. To use them, just prefix your current image with `flaudisio/asdf-`.

Examples:

| Image | ASDF-VM replacement |
|-------|---------------------|
| `alpine:3.19` | `flaudisio/asdf-alpine:3.19` |
| `python:3.11-alpine` | `flaudisio/asdf-python:3.11-alpine` |
| `python:3.11-slim` | `flaudisio/asdf-python:3.11-slim` |
| `python:3.12-alpine` | `flaudisio/asdf-python:3.12-alpine` |
| `python:3.12-slim` | `flaudisio/asdf-python:3.12-slim` |

## Environment variables

This image does not expect any environment variables.
