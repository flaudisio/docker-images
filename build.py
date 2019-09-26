#!/usr/bin/env python

import glob
import os
import subprocess
import sys
import yaml


DEBUG = os.getenv("DEBUG")
DRY_RUN = os.getenv("DRY_RUN")

DOCKER_REPOSITORY = os.getenv("DOCKER_REPOSITORY", "docker.io/flaudisio")

IMAGES_DIR = os.getenv("IMAGES_DIR", "images")
IMAGE = os.getenv("IMAGE", "all")

SPECFILE = "buildspec.yml"
DOCKERFILE = "Dockerfile"


class cd:
    """
    Context manager for changing the current working directory.
    """
    def __init__(self, new_path):
        self.new_path = os.path.expanduser(new_path)

    def __enter__(self):
        self.saved_path = os.getcwd()
        os.chdir(self.new_path)

    def __exit__(self, etype, value, traceback):
        os.chdir(self.saved_path)


def show_debug(message: str) -> None:
    if DEBUG:
        print(f"[DEBG] {message}")


def show_info(message: str) -> None:
    print(f"[INFO] {message}")


def show_warn(message: str) -> None:
    print(f"[WARN] {message}", file=sys.stderr)


def show_error(message: str, **kwargs) -> None:
    print(f"[ERROR] {message}", file=sys.stderr)

    if kwargs.get("exit"):
        sys.exit(1)


def get_image_dirs(image_name: str) -> list:
    """
    Return all image directories.
    """
    glob_path = "*" if image_name == "all" else image_name

    glob_result = glob.glob(os.path.join(os.getcwd(), IMAGES_DIR, glob_path))

    image_dirs = [i for i in glob_result if os.path.isdir(i)]

    return sorted(image_dirs)


def build_image(image_spec: dict, build_dir: str) -> None:
    image_name = image_spec["name"]

    for tag in image_spec.get("tags"):
        tag_name = tag["name"]
        tag_aliases = tag.get("aliases", [])
        build_args = tag.get("build_args", [])
        dockerfile = tag.get("dockerfile", DOCKERFILE)

        image_repo = f"{DOCKER_REPOSITORY}/{image_name}"
        image_fullname = f"{image_repo}:{tag_name}"

        docker_build_cmd = [
            "docker", "image", "build", "--rm", "--force-rm",
            f"--file={dockerfile}",
            f"--tag={image_fullname}",
            "."
        ]

        for build_arg in build_args:
            docker_build_cmd.append(f"--build-arg={build_arg}")

        show_info(f"Entering directory {build_dir}")
        show_info(f"Image: {image_fullname}")

        if DRY_RUN:
            show_info("Dry run mode enabled - won't build")
            continue

        with cd(build_dir):
            show_info(f"Building: " + " ".join(docker_build_cmd))
            subprocess.run(docker_build_cmd)

            for alias in tag_aliases:
                docker_tag_cmd = [
                    "docker", "image", "tag",
                    image_fullname,
                    f"{image_repo}:{alias}"
                ]

                show_info(f"Tagging: " + " ".join(docker_tag_cmd))
                subprocess.run(docker_tag_cmd)


def build_images(image_dirs: list) -> None:

    for image_dir in image_dirs:
        spec_filepath = os.path.join(image_dir, SPECFILE)

        if not os.path.exists(spec_filepath):
            show_info(f"Ignoring {image_dir} - file {SPECFILE} not found")
            continue

        with open(spec_filepath, "r") as spec_file:
            show_debug(f"Using file {spec_filepath}")

            try:
                buildspec = yaml.safe_load(spec_file)
            except yaml.YAMLError as exc:
                show_error(exc, exit=1)

            show_debug("Buildspec: {}".format(buildspec))

            for image in buildspec.get("images"):
                build_image(image_spec=image, build_dir=image_dir)


def main():
    image_dirs = get_image_dirs(image_name=IMAGE)

    if len(image_dirs) == 0:
        show_info(f"No directory found in '{IMAGES_DIR}/' - exiting")
        sys.exit(0)

    build_images(image_dirs)


if __name__ == '__main__':
    main()
