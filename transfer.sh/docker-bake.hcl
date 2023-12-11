# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "transfer_version" {
  default = "1.6.0"
}

target "default" {
  inherits = ["_template"]
  args = {
    transfer_version = transfer_version
  }
  tags = formatlist("%s/transfer.sh:%s", registries, transfer_version)
}
