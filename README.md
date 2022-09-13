# Docker Images

My collection of Docker images.

## Where are the `Dockerfile`s?

TL;DR:

```sh
find images/ -name 'Dockerfile*' | sort
```

This repository has the following image directories:

- [`images/base/`](images/base/): images derived from external images.  
  Example: `base/pre-commit` is built from `python:3-alpine`.

- [`images/child/`](images/child/): images derived from other images in this repository.  
  Example: `child/molecule` is built from `base/ansible`.

## Where are the images?

All images are [automatically](https://travis-ci.com/flaudisio/docker-images/builds)
(and regularly) pushed to [Docker Hub](https://hub.docker.com/u/flaudisio).

## Building

### Using the build script

Install the script requirements:

```sh
pip install -r builder/requirements.txt
```

Run it:

```sh
# Build all base images
IMAGES_DIR=images/base ./builder/build.py

# Build only the Ansible base image
IMAGES_DIR=images/base IMAGE=ansible ./builder/build.py
```

See the [`build.py` source](builder/build.py) for more options.

### Using `make`

Try the `*-images` targets. Example:

```sh
make images/base
make images/all

make image IMAGE_DIR=images/base/awscli
```

Run `make help` for all available commands.

### Using `docker build`

Just run `docker build` in some image directory:

```console
$ cd images/base/ansible
$ docker build -t my-ansible .
$ docker build -t my-ansible:2.7 . --build-arg ansible_version=2.7
```

## Adding a new image

To add a new image to this repository:

1. Install [Cookiecutter](https://cookiecutter.readthedocs.io/).

2. Run `make new` and answer some basic questions.

3. There's no step 3.

## License

[MIT](LICENSE).
