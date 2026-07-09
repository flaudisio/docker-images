# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "excalidraw_version" {
  default = "adf9631"
}

target "default" {
  inherits = ["_template"]
  args = {
    excalidraw_version = excalidraw_version
  }
  tags = formatlist("%s/excalidraw:%s", registries, excalidraw_version)
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}
