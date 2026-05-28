# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "hashibackup_version" {
  default = "0.3.0"
}

target "default" {
  inherits = ["_template"]
  tags     = formatlist("%s/hashibackup:%s", registries, hashibackup_version)
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}
