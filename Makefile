DOCKER_USERNAME ?= flaudisio

ENABLE_PUSH ?= false

ANSIBLE_VERSION ?= 2.8
PYTHON_VERSION ?= 3.7
MOLECULE_VERSION ?= 2

.build: IMAGE_NAME = $(DOCKER_USERNAME)/$(APP_NAME):$(APP_TAG)
.build:
	docker image build --rm --force-rm $(BUILD_ARGS) --tag "$(IMAGE_NAME)" "./$(APP_NAME)"
	if [ "$$ENABLE_PUSH" = "true" ] ; then \
	    docker image push "$(IMAGE_NAME)" ; \
	else \
	    echo "Ignoring push." ; \
	fi

ansible: APP_NAME=ansible
ansible: APP_TAG=$(ANSIBLE_VERSION)
ansible: BUILD_ARGS=--build-arg "ansible_version=$(ANSIBLE_VERSION)"
ansible: .build

molecule: APP_NAME=molecule
molecule: APP_TAG=ansible-$(ANSIBLE_VERSION)
molecule: BUILD_ARGS=--build-arg "parent_image=$(DOCKER_USERNAME)/ansible:$(ANSIBLE_VERSION)"
molecule: .build

cookiecutter: APP_NAME=cookiecutter
cookiecutter: APP_TAG=latest
cookiecutter: BUILD_ARGS=--build-arg "python_version=$(PYTHON_VERSION)"
cookiecutter: .build

pre-commit: APP_NAME=pre-commit
pre-commit: APP_TAG=latest
pre-commit: .build
