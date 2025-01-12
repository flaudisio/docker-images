# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "semaphore_versions" {
  default = [
    "2.11.2",
  ]
}

variable "ansible_versions" {
  default = [
    "2.16",
    "2.17",
  ]
}

target "default" {
  inherits   = ["_template"]
  name       = format("semaphore-%s-ansible-%s-%s", replace(semaphore_version, ".", "-"), replace(ansible_version, ".", "-"), distro)
  dockerfile = format("Dockerfile.%s", distro)
  matrix = {
    distro            = ["alpine", "debian"]
    ansible_version   = ansible_versions
    semaphore_version = semaphore_versions
  }
  args = {
    ansible_version   = ansible_version
    semaphore_version = semaphore_version
  }
  tags = formatlist("%s/semaphore-runner:%s-ansible-%s-%s", registries, semaphore_version, ansible_version, distro)
}
