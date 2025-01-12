# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "semaphore_versions" {
  default = [
    "2.11.1",
    "2.11.2",
  ]
}

target "default" {
  inherits = ["_template"]
  name     = format("semaphore-%s", replace(semaphore_version, ".", "-"))
  matrix = {
    semaphore_version = semaphore_versions
  }
  args = {
    semaphore_version = semaphore_version
  }
  tags = formatlist("%s/semaphore-server:%s", registries, semaphore_version)
}
