# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "claude_proxy_tag" {
  default = "0.3.1"
}

target "default" {
  inherits = ["_template"]
  args = {
    caddy_tag              = "2-alpine"
    routatic_proxy_version = "0.6.5"
  }
  tags = formatlist("%s/claude-proxy:%s", registries, claude_proxy_tag)
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}
