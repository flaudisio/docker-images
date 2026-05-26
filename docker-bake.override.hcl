variable "registries" {
  default = [
    "docker.io/flaudisio",
  ]
}

target "_template" {
  labels = {
    "org.opencontainers.image.authors" = "Flaudísio Tolentino <code+github@flaudisio.com>"
    "org.opencontainers.image.source"  = "https://github.com/flaudisio/docker-images"
  }
  platforms = [
    "linux/amd64",
  ]
}
