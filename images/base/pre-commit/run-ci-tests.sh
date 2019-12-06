#!/usr/bin/env bash

set -ex

bash --version
git --version
python --version
pip --version
pre-commit --version

pre-commit install

pre-commit run --all-files --color always
