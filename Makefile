BUILDER_CMD = ./builder/build.py

DOCKER_REPOSITORY ?= docker.io/flaudisio

export DOCKER_REPOSITORY

.PHONY: help test base-images child-images all-images list-images new-image

help:  ## Show available commands
	@echo "Available commands:"
	@echo
	@sed -n -E -e 's|^([a-z-]+):.+## (.+)|\1@\2|p' $(MAKEFILE_LIST) | column -s '@' -t

test:  ## Run test commands
	pre-commit run --all-files --verbose --show-diff-on-failure --color always

base-images:  ## Build the base images
	IMAGES_DIR=images/base $(BUILDER_CMD)

child-images:  ## Build the child images
	IMAGES_DIR=images/child $(BUILDER_CMD)

all-images: base-images child-images  ## Build ALL the things!

list-images:  ## List all images in the repository
	@echo "Available images:"
	@echo
	@find images/ -name 'Dockerfile*' | sed -e 's|^images/||' -e 's|/Dockerfile.*||' | sort | column -s '/' -t

new-image:  ## Add a new image to this repository
	cookiecutter cookiecutter/
