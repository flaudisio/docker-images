# Docker Images

My collection of Docker images.

## Where are the `Dockerfile`s?

TL;DR:

```sh
find images/ -name 'Dockerfile*' | sort
```

This repository has the following image directories:

- [`base-images/`](images/base-images/): images derived from external images.  
  Example: `base-images/pre-commit` is built from `python:3-alpine`.

- [`child-images/`](images/child-images/): images derived from other images in this repository.  
  Example: `child-images/molecule` is built from `base-images/ansible`.

## Where are the images?

All images are [automatically](https://travis-ci.com/flaudisio/docker-images/builds)
(and regularly) pushed to [Docker Hub](https://hub.docker.com/u/flaudisio).

## Building

Before building, please be sure to have the following tools available:

- Docker 1.13.0+
- Docker Compose 1.14.0+

### Using `make`

Try the `*-images` targets. Example:

```sh
make base-images
make base-images IMAGE=awscli

make child-images

make all-images
```

Run `make help` for all available commands.

### Using `docker build`

Just run `docker build` in some image directory:

```console
$ cd images/base-images/ansible
$ docker build -t my-ansible .
$ docker build -t my-ansible:2.7 . --build-arg ansible_version=2.7
```

### Using the build script

> **Note:** this is used while developing/testing the build script. I recommend
> the `make` instructions for general usage.

Install the script requirements:

```sh
pip install -r builder/requirements.txt
```

Run it:

```sh
# Build all base images
IMAGES_DIR=images/base-images ./builder/build.py

# Build only the Ansible base image
IMAGES_DIR=images/base-images IMAGE=ansible ./builder/build.py
```

See the [`build.py` source](builder/build.py) for more options.

## Adding a new image

To add a new image to this repository:

1. Install [Cookiecutter](https://cookiecutter.readthedocs.io/).

2. Run `make new` and answer some basic questions.

3. There's no step 3.

## License

[MIT](LICENSE).
