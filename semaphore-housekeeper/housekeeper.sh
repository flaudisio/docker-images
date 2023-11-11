#!/bin/sh

# shellcheck shell=dash

set -e
set -o pipefail


msg()
{
    echo "[housekeeper] $*" >&2
}

main()
{
    msg "Cleaning up Semaphore directory $SEMAPHORE_TMP_PATH"

    if ! rm -rf -- "${SEMAPHORE_TMP_PATH:-"/nonexistent"}"/* ; then
        msg "Warning: could not cleanup directory"
        exit
    fi
}


main "$@"
