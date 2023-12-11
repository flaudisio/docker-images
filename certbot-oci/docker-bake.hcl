# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "certbot_oci_version" {
  default = "0.3.0"
}

target "default" {
  inherits = ["_template"]
  args = {
    certbot_dns_cloudflare_version = "2.7.4"
    go_crond_version               = "23.2.0"
    oci_cli_version                = "3.36.1"
  }
  tags = formatlist("%s/certbot-oci:%s", registries, certbot_oci_version)
}
