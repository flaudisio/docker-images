BUILDER = ./builder/build.py

DOCKER_REPOSITORY ?= docker.io/flaudisio

export DOCKER_REPOSITORY

.PHONY: help lint image images/base images/all list-images new-image

help:  ## Show available commands
	@echo "Available commands:"
	@echo
	@sed -n -E -e 's|^([A-Za-z/_-]+): .+## (.+)|\1@\2|p' $(MAKEFILE_LIST) | column -s '@' -t

lint:  ## Run lint commands
	pre-commit run --all-files --verbose --show-diff-on-failure --color always

image:  ## Run the builder script
	$(BUILDER)

images/base:  ## Build all base images (same as 'make image IMAGE_DIR=images/base')
	$(BUILDER) IMAGE_DIR=images/base

images/all: images/base  ## Build all images (base, child, etc) in the right sequence

list-images: SHELL := /usr/bin/env bash
list-images:  ## List all images in the repository
	@echo "Available images:"
	@for dir in images/* ; do \
		echo -e "\n$$dir\n" ; \
		find "$$dir" -iname '*Dockerfile*' | sed -E -e "s|^$${dir}/|- |" -e 's|/Dockerfile.*||' | sort ; \
	done

new-image:  ## Add a new image to this repository
	cookiecutter cookiecutter/
