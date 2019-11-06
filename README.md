# Docker Images

My collection of Docker images.

## Where are the `Dockerfile`s?

TL;DR:

```sh
find *images -name Dockerfile
```

This repository has the following image directories:

- [`base-images/`](base-images/): images derived from external images.  
  Example: `base-images/pre-commit` is built from `python:3-alpine`.

- [`child-images/`](child-images/): images derived from other images built in this repository.  
  Example: `child-images/molecule` is built from `base-images/ansible`.

## Where are the images?

All images are automatically (and regularly) pushed to [Docker Hub](https://hub.docker.com/u/flaudisio)
by [Travis CI](https://travis-ci.com/flaudisio/docker-images/builds).

## Building

### Using the build script

First, install the script requirements:

```sh
pip install -r builder/requirements.txt
```

Then just run it. Here I have some examples:

```sh
# Build all images found in $PWD/images/
./builder/build.py

# Build image in $PWD/images/ansible
IMAGE=ansible ./builder/build.py

# Change the image search directory
IMAGES_DIR=base-images ./builder/build.py
```

See the [`build.py` source](builder/build.py) for more options.

### Using `make`

You may also use some `make` targets:

```sh
make base-images
make child-images
make all-images
```

Try `make help` for all available commands.

### Using `docker build`

Just run `docker build` in some image directory:

```console
$ cd base-images/ansible
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
