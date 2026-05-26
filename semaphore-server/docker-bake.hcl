# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "semaphore_versions" {
  default = [
    "2.17.39",
    "2.18.2",
  ]
}

target "default" {
  inherits = ["_template"]
  name     = format("semaphore-server-%s", replace(semaphore_version, ".", "-"))
  matrix = {
    semaphore_version = semaphore_versions
  }
  args = {
    semaphore_version = semaphore_version
  }
  tags = formatlist("%s/semaphore-server:%s", registries, semaphore_version)
}
