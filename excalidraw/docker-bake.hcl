# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "excalidraw_version" {
  default = "0.17.0"
}

target "default" {
  inherits = ["_template"]
  args = {
    excalidraw_version = excalidraw_version
  }
  tags = formatlist("%s/excalidraw:%s", registries, excalidraw_version)
}
