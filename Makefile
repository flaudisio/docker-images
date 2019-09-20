DOCKER_USERNAME ?= flaudisio

ENABLE_PUSH ?= false

ANSIBLE_VERSION ?= 2.8

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

pre-commit: APP_NAME=pre-commit
pre-commit: APP_TAG=latest
pre-commit: .build
