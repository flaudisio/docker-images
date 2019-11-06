.PHONY: base-images child-images all-images help

base-images:  ## Build the base images
	IMAGES_DIR=base-images ./builder/build.py

child-images:  ## Build the child images
	IMAGES_DIR=child-images ./builder/build.py

all-images: base-images child-images  ## Build ALL the things!

help:  ## Show available commands
	@echo "Available commands:"
	@echo
	@sed -n -E -e 's|^([a-z-]+):.+## (.+)|\1@\2|p' $(MAKEFILE_LIST) | column -s '@' -t
