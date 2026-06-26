# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "semaphore_versions" {
  default = [
    "2.18.13",
  ]
}

variable "ansible_versions" {
  default = [
    "2.20",
  ]
}

target "base" {
  name       = format("base-%s", replace(semaphore_version, ".", "-"))
  dockerfile = "Dockerfile.base"
  matrix = {
    semaphore_version = semaphore_versions
  }
  args = {
    semaphore_version = semaphore_version
  }
  output = [{ type = "cacheonly" }]
}

target "server" {
  inherits = ["_template"]
  name     = format("semaphore-server-%s", replace(semaphore_version, ".", "-"))
  contexts = {
    base-image = format("target:base-%s", replace(semaphore_version, ".", "-"))
  }
  dockerfile = "Dockerfile.server"
  matrix = {
    semaphore_version = semaphore_versions
  }
  args = {
    semaphore_version = semaphore_version
  }
  tags = formatlist("%s/semaphore-server:%s", registries, semaphore_version)
}

target "runner" {
  inherits = ["_template"]
  name     = format("semaphore-runner-%s-ansible-%s", replace(semaphore_version, ".", "-"), replace(ansible_version, ".", "-"))
  contexts = {
    base-image = format("target:base-%s", replace(semaphore_version, ".", "-"))
  }
  dockerfile = "Dockerfile.runner"
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

group "default" {
  targets = [
    "server",
    "runner",
  ]
}
