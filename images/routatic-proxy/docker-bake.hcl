# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "routatic_proxy_version" {
  default = "0.6.5"
}

target "default" {
  inherits = ["_template"]
  args = {
    caddy_tag              = "2-alpine"
    routatic_proxy_version = routatic_proxy_version
  }
  tags = concat(
    formatlist("%s/routatic-proxy:%s", registries, routatic_proxy_version),
    formatlist("%s/routatic-proxy:latest", registries),
  )
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}
