variable "registries" {
  default = [
    "docker.io/flaudisio",
    // "ghcr.io/flaudisio",
  ]
}

group "default" {
  targets = []
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
