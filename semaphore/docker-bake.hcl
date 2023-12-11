# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "semaphore_versions" {
  default = [
    "2.8.90",
    "2.9.37",
  ]
}

variable "ansible_version" {
  default = "2.15.*"
}

target "default" {
  inherits   = ["_template"]
  name       = format("semaphore-%s-%s", replace(semaphore_version, ".", "-"), distro)
  context    = "semaphore"
  dockerfile = format("%s.Dockerfile", distro)
  matrix = {
    distro            = ["alpine", "debian"]
    semaphore_version = semaphore_versions
  }
  args = {
    ansible_version   = ansible_version
    semaphore_version = semaphore_version
  }
  tags = formatlist("%s/semaphore:%s-%s", registries, semaphore_version, distro)
}
