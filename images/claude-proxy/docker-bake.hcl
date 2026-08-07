# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "claudeproxy_tag" {
  default = "0.2.0"
}

target "default" {
  inherits = ["_template"]
  args = {
    caddy_tag          = "2-alpine"
    routatic_proxy_tag = "0.6.2"
  }
  tags = formatlist("%s/claudeproxy:%s", registries, claudeproxy_tag)
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}
