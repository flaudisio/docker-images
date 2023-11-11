variable "registries" {
  default = [
    "docker.io/flaudisio",
    // "ghcr.io/flaudisio",
  ]
}

group "default" {
  targets = [
    "asdf",
    "certbot-oci",
    "excalidraw",
    "pre-commit",
    "semaphore-housekeeper",
    "semaphore",
    "transfer-sh",
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

target "certbot-oci" {
  inherits = ["_template"]
  context  = "certbot-oci"
  args = {
    certbot_dns_cloudflare_version = "2.7.4"
    go_crond_version               = "23.2.0"
    oci_cli_version                = "3.36.1"
  }
  tags = formatlist("%s/certbot-oci:0.3.0", registries)
}

target "excalidraw" {
  inherits = ["_template"]
  context  = "excalidraw"
  args = {
    excalidraw_version = "0.16.1"
  }
  tags = formatlist("%s/excalidraw:0.16.1", registries)
}

target "pre-commit" {
  inherits   = ["_template"]
  name       = format("pre-commit-%s-%s", major_version, distro)
  context    = "pre-commit"
  dockerfile = format("%s.Dockerfile", distro)
  matrix = {
    distro        = ["alpine", "debian"]
    major_version = ["2", "3"]
  }
  args = {
    pre_commit_version = format("%s.*", major_version)
  }
  tags = concat(
    formatlist("%s/pre-commit:%s", registries, distro),
    formatlist("%s/pre-commit:%s-%s", registries, major_version, distro),
  )
}

target "semaphore" {
  inherits   = ["_template"]
  name       = format("semaphore-%s-%s", replace(semaphore, ".", "-"), distro)
  context    = "semaphore"
  dockerfile = format("%s.Dockerfile", distro)
  matrix = {
    distro    = ["alpine", "debian"]
    semaphore = ["2.8.90", "2.9.37"]
  }
  args = {
    ansible_version   = "2.15.*"
    semaphore_version = semaphore
  }
  tags = formatlist("%s/semaphore:%s-%s", registries, semaphore, distro)
}

target "semaphore-housekeeper" {
  inherits = ["_template"]
  context  = "semaphore-housekeeper"
  args = {
    go_crond_version = "23.2.0"
  }
  tags = formatlist("%s/semaphore-housekeeper:0.1.0", registries)
}

target "transfer-sh" {
  inherits = ["_template"]
  context  = "transfer.sh"
  args = {
    transfer_version = "1.6.0"
  }
  tags = formatlist("%s/transfer.sh:1.6.0", registries)
}
