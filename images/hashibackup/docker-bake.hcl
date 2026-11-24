# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "hashibackup_version" {
  default = "0.3.2"
}

target "default" {
  inherits = ["_template"]
  args = {
    consul_version = "2.1.0"
    nomad_version  = "2.1.1"
  }
  tags = concat(
    formatlist("%s/hashibackup:%s", registries, hashibackup_version),
    formatlist("%s/hashibackup:latest", registries),
  )
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}
