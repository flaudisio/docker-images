#!/bin/sh

set -e

export PYTHONUNBUFFERED=1

if [ "$ENABLE_PUSH" = "true" ] ; then
    echo "==> Logging on Docker Hub"
    echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin
    echo
fi

case $1 in
    build)
        shift
        echo "==> Running build script"
        echo
        exec pydib "$@"
    ;;
esac

exec "$@"
