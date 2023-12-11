# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "asdf_version" {
  default = "0.13.1"
}

target "default" {
  inherits   = ["_template"]
  name       = format("asdf-%s-%s", item.base_image_repo, replace(item.base_image_tag, ".", "-"))
  dockerfile = format("%s.Dockerfile", item.distro)
  matrix = {
    item = [
      # Alpine-based
      {
        distro          = "alpine"
        base_image_repo = "alpine"
        base_image_tag  = "3.18"
      },
      {
        distro          = "alpine"
        base_image_repo = "python"
        base_image_tag  = "3.10-alpine"
      },
      # Debian-based
      {
        distro          = "debian"
        base_image_repo = "python"
        base_image_tag  = "3.10-slim"
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
