# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "keeweb_version" {
  default = "1.18.9"
}

target "default" {
  inherits = ["_template"]
  args = {
    keeweb_version = keeweb_version
  }
  tags = formatlist("%s/keeweb:%s", registries, keeweb_version)
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}
