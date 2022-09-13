#!/usr/bin/env python3
#
# build.py
# Script to build multiple Docker images.
#
##

import coloredlogs
import logging
import os
import subprocess
import sys
import yaml

from datetime import datetime


logger = logging.getLogger(__name__)

coloredlogs.DEFAULT_LEVEL_STYLES["debug"] = {
    "color": "blue",
    "bold": True
}

coloredlogs.DEFAULT_LEVEL_STYLES["info"] = {
    "color": "green",
    "bold": True
}

coloredlogs.DEFAULT_LEVEL_STYLES["warning"] = {
    "color": "yellow",
    "bold": True
}

coloredlogs.DEFAULT_LEVEL_STYLES["error"] = {
    "color": "red",
    "bold": True
}

coloredlogs.install(
    level="INFO",
    fmt="[%(levelname)s] [%(module)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S %z"
)

PROGRAM_NAME = "pyDIB"
PROGRAM_VERSION = "0.1.0"

DEBUG = os.getenv("DEBUG")
DRY_RUN = os.getenv("DRY_RUN")
NO_CACHE = os.getenv("NO_CACHE")

ENABLE_PULL = os.getenv("ENABLE_PULL")
ENABLE_PUSH = os.getenv("ENABLE_PUSH")

DISABLE_TESTS = os.getenv("DISABLE_TESTS")

DOCKER_REPOSITORY = os.getenv("DOCKER_REPOSITORY")

IMAGE_DIR = os.getenv("IMAGE_DIR", "images")

GOSS_PATH = os.getenv("GOSS_PATH", "/usr/local/bin/goss")
GOSS_SLEEP = os.getenv("GOSS_SLEEP", 0.2)

DEFAULTS = {
    "dockerfile": "Dockerfile",
    "spec_file": "buildspec.yml",
    "test_spec": {
        "file": "test.yaml",
        "entrypoint": None,
        "command": None,
        "env": {},
        "sleep": GOSS_SLEEP
    }
}


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


def get_image_dirs(search_path: str) -> list:
    """
    Return a list of all image directories found in `search_path`.
    """
    spec_file = DEFAULTS["spec_file"]
    logger.info(f"Searching directories containing '{spec_file}'")

    abs_search_path = os.path.abspath(search_path)

    image_dirs = [
        # 'item' example: ('/pato/to/images/base', ['subdir'], ['Dockerfile', 'buildspec.yml'])
        item[0] for item in os.walk(abs_search_path)
        if spec_file in item[2]
    ]

    logger.debug("Image directories:")
    [logger.debug(f"- {image_dir}") for image_dir in image_dirs]

    return sorted(image_dirs)


def run_cmd(command: list, **kwargs: dict) -> None:
    """
    Run `command` using `subprocess.run()`.
    """
    logger.info(f"Command: {' '.join(command)}")

    if DRY_RUN:
        logger.info("Dry run mode enabled - won't run")
        return

    extra_env = kwargs.get("env", {})

    # Merge extra environment variables with the current ones
    cmd_env = {**os.environ, **extra_env}

    subprocess.run(command, env=cmd_env, check=True)


def push_image(image: str) -> None:
    """
    Push the Docker `image`.
    """
    if not ENABLE_PUSH:
        logger.info("Not pushing - ENABLE_PUSH not set")
        return

    try:
        run_cmd(["docker", "image", "push", image])
    except Exception:
        logger.error(f"Error pushing image {image}; aborting")
        sys.exit(1)


def get_test_spec(build_spec: dict) -> dict:
    default_test_spec = DEFAULTS["test_spec"]

    test_spec = build_spec.get("tests", {})

    try:
        return {**default_test_spec, **test_spec}
    except Exception as exc:
        logger.warning(f"Error loading test spec: {exc}")
        return {}


def test_image(image_name: str, image_dir: str, test_spec: dict) -> None:
    """
    Run tests for `image`.
    """
    if DISABLE_TESTS:
        logger.warning("DISABLE_TESTS is set; skipping tests")
        return

    if not test_spec:
        logger.warning("Test spec undefined; skipping tests")
        return

    goss_filepath = os.path.join(image_dir, test_spec["file"])

    if not os.path.isfile(goss_filepath):
        logger.warning(f"Test spec file {goss_filepath} not found; skipping tests")
        return

    test_entrypoint = test_spec["entrypoint"]
    test_cmd = test_spec["command"]
    test_env = test_spec["env"]

    dgoss_cmd = ["dgoss", "run", "--tty"]

    if test_entrypoint is not None:
        dgoss_cmd.extend(["--entrypoint", test_entrypoint])

    [dgoss_cmd.extend(["-e", f"{var}={test_env[var]}"]) for var in test_spec["env"]]

    dgoss_cmd.append(image_name)

    if test_cmd:
        try:
            dgoss_cmd.extend(test_cmd.split())  # if test_cmd is a string
        except AttributeError:
            dgoss_cmd.extend(test_cmd)  # if test_cmd is already a list

    dgoss_env_vars = {
        "GOSS_PATH": GOSS_PATH,
        "GOSS_FILES_STRATEGY": "cp",
        "GOSS_FILES_PATH": image_dir,
        "GOSS_FILE": test_spec["file"],
        "GOSS_SLEEP": str(test_spec["sleep"]),
        "GOSS_OPTS": "--color --format tap"
    }

    logger.info("Running tests")

    logger.debug(f"Test spec: {test_spec}")
    [logger.debug(f"{var} = {dgoss_env_vars[var]}") for var in dgoss_env_vars]

    try:
        run_cmd(dgoss_cmd, env=dgoss_env_vars)
    except Exception:
        logger.error(f"Error testing {image_name}; aborting")
        sys.exit(1)

    logger.info(f"Image {image_name} successfully tested!")


def build_image(image: dict, build_dir: str, test_spec: dict) -> None:
    """
    Build a Docker image in `build_dir` based on `image_spec`.
    """
    image_name = image["name"]

    for tag in image.get("tags"):
        tag_name = tag["name"]
        build_args = tag.get("build_args", [])
        dockerfile = tag.get("dockerfile", DEFAULTS["dockerfile"])

        image_repo = f"{DOCKER_REPOSITORY}/{image_name}"
        full_image_name = f"{image_repo}:{tag_name}"

        docker_build_cmd = [
            "docker", "image", "build", "--rm", "--force-rm",
            "--file", dockerfile,
            "--tag", full_image_name,
            "."
        ]

        if NO_CACHE:
            docker_build_cmd.append("--no-cache")

        if ENABLE_PULL:
            docker_build_cmd.append("--pull")

        [docker_build_cmd.extend(["--build-arg", arg]) for arg in build_args]

        logger.info(f"Entering directory {build_dir}")
        logger.info(f"Image: {full_image_name}")

        with cd(build_dir):
            try:
                run_cmd(docker_build_cmd)
            except Exception:
                logger.error(f"Error building {full_image_name}; aborting")
                sys.exit(1)

            logger.info(f"Image {full_image_name} successfully built!")

            test_image(full_image_name, build_dir, test_spec)

            push_image(full_image_name)

            tag_aliases = tag.get("aliases", [])

            for tag_alias in tag_aliases:
                full_tag_alias = f"{image_repo}:{tag_alias}"

                logger.info(f"Tag alias: {full_tag_alias}")

                docker_tag_cmd = [
                    "docker", "image", "tag", full_image_name, full_tag_alias
                ]

                try:
                    run_cmd(docker_tag_cmd)
                except Exception:
                    logger.error(f"Error creating tag {full_tag_alias}; aborting")
                    sys.exit(1)

                test_image(full_tag_alias, build_dir, test_spec)

                push_image(full_tag_alias)


def load_spec_file(filepath: str) -> dict:
    """
    Parse a build spec file and return its data as a dict.
    """
    build_spec = {}

    logger.debug(f"Loading file {filepath}")

    with open(filepath, "r") as spec_file:
        try:
            build_spec = yaml.safe_load(spec_file)
        except yaml.YAMLError as exc:
            logger.error(f"Error loading build spec file:\n\n{exc}")
            sys.exit(1)

        logger.debug(f"build spec: {build_spec}")

    return build_spec


def build_images(image_dirs: list) -> None:
    """
    Build all images found in `image_dirs`.
    """
    spec_file = DEFAULTS["spec_file"]

    for image_dir in image_dirs:
        spec_filepath = os.path.join(image_dir, spec_file)
        build_spec = load_spec_file(spec_filepath)

        images = build_spec["images"]
        test_spec = get_test_spec(build_spec)

        for image in images:
            build_image(image=image, build_dir=image_dir, test_spec=test_spec)


def main():
    """
    Entrypoint function.
    """
    current_datetime = datetime.now()
    timestamp = datetime.astimezone(current_datetime).strftime("%Y-%m-%d %H:%M:%S %z")

    logger.info(f"Starting {PROGRAM_NAME} v{PROGRAM_VERSION} at {timestamp}")

    if not DOCKER_REPOSITORY:
        logger.error("Environment variable DOCKER_REPOSITORY is not set.")
        sys.exit(2)

    if DEBUG:
        coloredlogs.set_level("DEBUG")

    image_dirs = get_image_dirs(search_path=IMAGE_DIR)

    if len(image_dirs) == 0:
        logger.info(f"No images found in '{IMAGE_DIR}' - exiting")
        sys.exit(0)

    build_images(image_dirs)


if __name__ == "__main__":
    main()
