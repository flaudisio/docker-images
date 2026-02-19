#!/bin/bash

set -e
set -o pipefail

case "$1" in
    hashibackup)
        shift
        exec hashibackup "$@"
    ;;
esac

exec "$@"
