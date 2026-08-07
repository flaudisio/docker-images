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
  tags = formatlist("%s/transfer.sh:%s-%s", registries, transfer_version, image_release)
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}
