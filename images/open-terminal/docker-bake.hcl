# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "open_terminal_tag" {
  default = "0.14.0-slim"
}

target "default" {
  inherits = ["_template"]
  args = {
    open_terminal_tag = open_terminal_tag
    mise_version      = "v2026.10.8"
  }
  tags = formatlist("%s/open-terminal:%s", registries, open_terminal_tag)
}
