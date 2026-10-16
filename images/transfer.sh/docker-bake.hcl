# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "transfer_version" {
  default = "1.6.1"
}

variable "image_release" {
  default = "2"
}

target "default" {
  inherits = ["_template"]
  args = {
    transfer_version = transfer_version
  }
  tags = concat(
    formatlist("%s/transfer.sh:%s-%s", registries, transfer_version, image_release),
    formatlist("%s/transfer.sh:latest", registries),
  )
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}
