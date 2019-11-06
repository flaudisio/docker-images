.PHONY: help builder base-images child-images all-images clean new

help:  ## Show available commands
	@echo "Available commands:"
	@echo
	@sed -n -E -e 's|^([a-z-]+):.+## (.+)|\1@\2|p' $(MAKEFILE_LIST) | column -s '@' -t

builder:  ## Create the builder-image
	docker-compose build

base-images:  ## Build the base images
	IMAGES_DIR=images/base-images docker-compose run --rm builder

child-images:  ## Build the child images
	IMAGES_DIR=images/child-images docker-compose run --rm builder

all-images: base-images child-images  ## Build ALL the things!

clean:
	docker-compose down -v

new:  ## Add a new image to this repository
	cookiecutter cookiecutter/
