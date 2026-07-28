# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "autobrr_tag" {
  default = "v1.82.1"
}

target "default" {
  inherits = ["_template"]
  args = {
    autobrr_tag = autobrr_tag
  }
  tags = formatlist("%s/autobrr:%s", registries, autobrr_tag)
}
