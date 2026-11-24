# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "image_tag" {
  default = "0.4.0"
}

target "default" {
  inherits = ["_template"]
  args = {
    lego_version     = "5.7.0"
    go_crond_version = "26.10.0"
    oci_cli_version  = "3.96.0"
  }
  tags = concat(
    formatlist("%s/acme-oci:%s", registries, image_tag),
    formatlist("%s/acme-oci:latest", registries),
  )
}
