# NOTE: see 'docker-bake.override.hcl' for common configuration

variable "pre_commit_major_versions" {
  default = ["2", "3", "4"]
}

target "default" {
  inherits   = ["_template"]
  name       = format("pre-commit-%s-%s", major_version, distro)
  dockerfile = format("Dockerfile.%s", distro)
  matrix = {
    distro        = ["alpine", "debian"]
    major_version = pre_commit_major_versions
  }
  args = {
    pre_commit_version = format("%s.*", major_version)
  }
  tags = concat(
    formatlist("%s/pre-commit:%s-%s", registries, major_version, distro),                             # :2-alpine, :3-debian
    distro == "alpine" ? formatlist("%s/pre-commit:%s", registries, major_version) : [],              # :2, :3
    major_version == "4" ? formatlist("%s/pre-commit:%s", registries, distro) : [],                   # :alpine, :debian
    major_version == "4" && distro == "alpine" ? formatlist("%s/pre-commit:latest", registries) : [], # :latest
  )
}
