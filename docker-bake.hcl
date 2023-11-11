variable "registries" {
  default = [
    "docker.io/flaudisio",
    // "ghcr.io/flaudisio",
  ]
}

group "default" {
  targets = [
    "asdf",
    "pre-commit",
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
    asdf_version    = "0.13.1"
    base_image_repo = item.base_image_repo
    base_image_tag  = item.base_image_tag
  }
  tags = formatlist("%s/asdf-%s:%s", registries, item.base_image_repo, item.base_image_tag)
}

target "pre-commit" {
  inherits   = ["_template"]
  name       = format("pre-commit-%s-%s", major_version, distro)
  context    = "pre-commit"
  dockerfile = format("%s.Dockerfile", distro)
  matrix = {
    distro        = ["alpine", "debian"]
    major_version = ["2"]
  }
  args = {
    pre_commit_version = format("%s.*", major_version)
  }
  tags = concat(
    formatlist("%s/pre-commit:%s", registries, distro),
    formatlist("%s/pre-commit:%s-%s", registries, major_version, distro),
  )
}
