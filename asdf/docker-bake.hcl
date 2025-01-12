# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "asdf_version" {
  default = "0.14.0"
}

target "default" {
  inherits   = ["_template"]
  name       = format("asdf-%s-%s", item.base_image_repo, replace(item.base_image_tag, ".", "-"))
  dockerfile = format("Dockerfile.%s", item.distro)
  matrix = {
    item = [
      # Alpine-based
      {
        distro          = "alpine"
        base_image_repo = "alpine"
        base_image_tag  = "3.20"
      },
      {
        distro          = "alpine"
        base_image_repo = "alpine"
        base_image_tag  = "3.21"
      },
      {
        distro          = "alpine"
        base_image_repo = "python"
        base_image_tag  = "3.10-alpine"
      },
      {
        distro          = "alpine"
        base_image_repo = "python"
        base_image_tag  = "3.11-alpine"
      },
      {
        distro          = "alpine"
        base_image_repo = "python"
        base_image_tag  = "3.12-alpine"
      },
      {
        distro          = "alpine"
        base_image_repo = "python"
        base_image_tag  = "3.13-alpine"
      },
      # Debian-based
      {
        distro          = "debian"
        base_image_repo = "python"
        base_image_tag  = "3.10-slim"
      },
      {
        distro          = "debian"
        base_image_repo = "python"
        base_image_tag  = "3.11-slim"
      },
      {
        distro          = "debian"
        base_image_repo = "python"
        base_image_tag  = "3.12-slim"
      },
      {
        distro          = "debian"
        base_image_repo = "python"
        base_image_tag  = "3.13-slim"
      },
    ]
  }
  args = {
    asdf_version    = asdf_version
    base_image_repo = item.base_image_repo
    base_image_tag  = item.base_image_tag
  }
  tags = formatlist("%s/asdf-%s:%s", registries, item.base_image_repo, item.base_image_tag)
}
