BUILDER = ./builder/build.py

DOCKER_REPOSITORY ?= docker.io/flaudisio

export DOCKER_REPOSITORY

.PHONY: help
help:  ## Show available commands
	@echo "Available commands:"
	@echo
	@sed -n -E -e 's|^([A-Za-z/_-]+): .+## (.+)|\1@\2|p' $(MAKEFILE_LIST) | column -s '@' -t

.PHONY: lint
lint:  ## Run lint commands
	pre-commit run --all-files --verbose --show-diff-on-failure --color always

.PHONY: image
image:  ## Run the builder script
	$(BUILDER)

.PHONY: images/base
images/base:  ## Build all base images (same as 'make image IMAGE_DIR=images/base')
	IMAGE_DIR=images/base $(BUILDER)

.PHONY: images/child
images/child:  ## Build all child images (same as 'make image IMAGE_DIR=images/child')
	IMAGE_DIR=images/child $(BUILDER)

.PHONY: images/all
images/all: images/base images/child  ## Build all images (base, child, etc) in the right sequence

.PHONY: list-images
list-images: SHELL := /usr/bin/env bash
list-images:  ## List all images in the repository
	@echo "Available images:"
	@for dir in images/* ; do \
		echo -e "\n$$dir\n" ; \
		find "$$dir" -iname '*Dockerfile*' | sed -E -e "s|^$${dir}/|- |" -e 's|/Dockerfile.*||' | sort ; \
	done

.PHONY: new-image
new-image:  ## Add a new image to this repository
	cookiecutter cookiecutter/
