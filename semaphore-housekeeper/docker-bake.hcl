# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "image_tag" {
  default = "0.1.0"
}

target "default" {
  inherits = ["_template"]
  args = {
    go_crond_version = "23.2.0"
  }
  tags = formatlist("%s/semaphore-housekeeper:%s", registries, image_tag)
}
