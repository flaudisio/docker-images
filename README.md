# Docker Images

Some useful Docker images.

## Building via script

You can use the `build.py` script:

```console
$ pip install -r requirements.txt

$ ./build.py
$ IMAGE=ansible ./build.py
```

The first command will build **all** images and tags defined in `images/*/buildspec.yml`.

The second one will build all images and tags defined in `images/ansible/buildspec.yml`.

See the [`build.py` source](build.py) for other options.

## Building directly with Docker

Just run `docker build` in some image directory:

```console
$ cd images/ansible
$ docker build -t my-ansible .
$ docker build -t my-ansible:2.7 . --build-arg ansible_version=2.7
```

## Adding a new image

Install [Cookiecutter](https://cookiecutter.readthedocs.io/) and run `./add-image.sh`.

## License

[MIT](LICENSE).
