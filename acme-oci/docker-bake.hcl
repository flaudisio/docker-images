# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "acme_oci_version" {
  default = "0.2.0"
}

target "default" {
  inherits = ["_template"]
  args = {
    lego_version     = "4.16.1"
    go_crond_version = "23.12.0"
    oci_cli_version  = "3.37.13"
  }
  tags = formatlist("%s/acme-oci:%s", registries, acme_oci_version)
}
