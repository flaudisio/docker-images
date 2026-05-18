# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "semaphore_versions" {
  default = [
    "2.17.39",
    "2.18.2",
  ]
}

variable "ansible_versions" {
  default = [
    "2.17",
  ]
}

target "default" {
  inherits = ["_template"]
  name     = format("semaphore-runner-%s-ansible-%s", replace(semaphore_version, ".", "-"), replace(ansible_version, ".", "-"))
  matrix = {
    ansible_version   = ansible_versions
    semaphore_version = semaphore_versions
  }
  args = {
    ansible_version   = ansible_version
    semaphore_version = semaphore_version
  }
  tags = formatlist("%s/semaphore-runner:%s-ansible-%s", registries, semaphore_version, ansible_version)
}
