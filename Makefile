BUILDER_CMD = ./builder/build.py

DOCKER_REPOSITORY ?= docker.io/flaudisio

export DOCKER_REPOSITORY

.PHONY: help base-images child-images all-images new

help:  ## Show available commands
	@echo "Available commands:"
	@echo
	@sed -n -E -e 's|^([a-z-]+):.+## (.+)|\1@\2|p' $(MAKEFILE_LIST) | column -s '@' -t

base-images:  ## Build the base images
	IMAGES_DIR=images/base-images $(BUILDER_CMD)

child-images:  ## Build the child images
	IMAGES_DIR=images/child-images $(BUILDER_CMD)

all-images: base-images child-images  ## Build ALL the things!


new:  ## Add a new image to this repository
	cookiecutter cookiecutter/
