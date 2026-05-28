# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "hashibackup_version" {
  default = "0.3.0"
}

target "default" {
  inherits = ["_template"]
  args = {
    consul_version = "2.0.0"
    nomad_version  = "2.0.2"
  }
  tags = formatlist("%s/hashibackup:%s", registries, hashibackup_version)
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}
