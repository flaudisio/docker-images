#!/usr/bin/env python3
#
# build.py
# Script to build multiple Docker images.
#
##

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
ENABLE_PUSH = os.getenv("ENABLE_PUSH")

SPECFILE = "buildspec.yml"
DOCKERFILE = "Dockerfile"


class bcolors:
    NORMAL = "\033[0m"
    BLUE = "\033[1;94m"
    GREEN = "\033[1;92m"
    YELLOW = "\033[1;93m"
    RED = "\033[1;91m"


class cd:
    """Context manager for changing the current working directory."""
    def __init__(self, new_path):
        self.new_path = os.path.expanduser(new_path)

    def __enter__(self):
        self.saved_path = os.getcwd()
        os.chdir(self.new_path)

    def __exit__(self, etype, value, traceback):
        os.chdir(self.saved_path)


def show_debug(message: str) -> None:
    """Show a debug message."""
    if DEBUG:
        print(f"{bcolors.BLUE}[DEBG] {message}{bcolors.NORMAL}")


def show_info(message: str) -> None:
    """Show an information message."""
    print(f"{bcolors.GREEN}[INFO] {message}{bcolors.NORMAL}")


def show_warn(message: str) -> None:
    """Show a warning message."""
    print(f"{bcolors.YELLOW}[WARN] {message}{bcolors.NORMAL}", file=sys.stderr)


def show_error(message: str, **kwargs) -> None:
    """Show an error message."""
    print(f"{bcolors.RED}[ERROR] {message}{bcolors.NORMAL}", file=sys.stderr)

    if kwargs.get("exit"):
        sys.exit(1)


def get_image_dirs(image_name: str) -> list:
    """Return a list of all image directories."""
    glob_path = "*" if image_name == "all" else image_name

    glob_result = glob.glob(os.path.join(os.getcwd(), IMAGES_DIR, glob_path))

    image_dirs = [i for i in glob_result if os.path.isdir(i)]

    return sorted(image_dirs)


def run_cmd(command: list) -> None:
    """Run `command` using `subprocess.run()`."""
    show_info(f"Command: {' '.join(command)}")

    if DRY_RUN:
        show_info("Dry run mode enabled - won't run")
    else:
        subprocess.run(command)


def push_image(image: str) -> None:
    if not ENABLE_PUSH:
        show_info("Not pushing - ENABLE_PUSH not set")
        return

    run_cmd(["docker", "image", "push", image])


def build_image(image_spec: dict, build_dir: str) -> None:
    """Build a Docker image in `build_dir` based on `image_spec`."""
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

        with cd(build_dir):
            run_cmd(docker_build_cmd)
            push_image(image_fullname)

            for tag_alias in tag_aliases:
                image_alias_name = f"{image_repo}:{tag_alias}"

                show_info(f"Tag alias: {image_alias_name}")

                docker_tag_cmd = [
                    "docker", "image", "tag", image_fullname, image_alias_name
                ]

                run_cmd(docker_tag_cmd)
                push_image(image_alias_name)


def load_specfile(filepath: str) -> dict:
    """Parse a spec file and return its data as a dict."""
    buildspec = {}

    with open(filepath, "r") as spec_file:
        show_debug(f"Using file {filepath}")

        try:
            buildspec = yaml.safe_load(spec_file)
        except yaml.YAMLError as exc:
            show_error(exc, exit=1)

        show_debug(f"Buildspec: {buildspec}")

    return buildspec


def build_all_images(image_dirs: list) -> None:
    """Build all images found in `image_dirs`."""
    show_debug(f"Searching directories: {image_dirs}")

    for image_dir in image_dirs:
        spec_filepath = os.path.join(image_dir, SPECFILE)

        if not os.path.exists(spec_filepath):
            show_info(f"Ignoring {image_dir} - file {SPECFILE} not found")
            continue

        buildspec = load_specfile(spec_filepath)

        for image in buildspec["images"]:
            build_image(image_spec=image, build_dir=image_dir)


def main():
    """Entrypoint function."""
    image_dirs = get_image_dirs(image_name=IMAGE)

    if len(image_dirs) == 0:
        show_info(f"No directory found in '{IMAGES_DIR}/' - exiting")
        sys.exit(0)

    build_all_images(image_dirs)


if __name__ == "__main__":
    main()
