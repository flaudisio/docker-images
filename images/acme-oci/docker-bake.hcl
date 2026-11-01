# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "image_tag" {
  default = "0.4.0"
}

target "default" {
  inherits = ["_template"]
  args = {
    lego_version     = "4.35.2"
    go_crond_version = "23.12.0"
    oci_cli_version  = "3.89.3"
  }
  tags = concat(
    formatlist("%s/acme-oci:%s", registries, image_tag),
    formatlist("%s/acme-oci:latest", registries),
  )
}
