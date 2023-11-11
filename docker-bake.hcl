variable "registries" {
  default = [
    "docker.io/flaudisio",
    // "ghcr.io/flaudisio",
  ]
}

group "default" {
  targets = [
    "asdf",
  ]
}

target "_template" {
  labels = {
    "org.opencontainers.image.source" = "https://github.com/flaudisio/docker-images"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}

target "asdf" {
  inherits   = ["_template"]
  name       = format("asdf-%s-%s", item.base_image_repo, replace(item.base_image_tag, ".", "-"))
  context    = "asdf"
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
    asdf_version    = "0.10.2"
    base_image_repo = item.base_image_repo
    base_image_tag  = item.base_image_tag
  }
  tags = formatlist("%s/asdf-%s:%s", registries, item.base_image_repo, item.base_image_tag)
}
