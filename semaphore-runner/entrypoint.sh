#!/usr/bin/env bash

set -e
set -o pipefail

: "${SSH_LOG_LEVEL:="ERROR"}"

_msg()
{
    echo "$( date +'%Y-%m-%d %T %Z' ) [entrypoint] $*" >&2
}

configure_ssh_client()
{
    _msg "Configuring SSH client"

    if ! grep -q 'entrypoint.sh' /etc/ssh/ssh_config ; then
        printf "# entrypoint.sh\nHost *\n  LogLevel %s\n" "$SSH_LOG_LEVEL" >> /etc/ssh/ssh_config
    fi
}

set_files_ownership()
{
    if [[ -z "$SEMAPHORE_TMP_PATH" ]] ; then
        return
    fi

    if [[ ! -d "$SEMAPHORE_TMP_PATH" ]] ; then
        _msg "Creating $SEMAPHORE_TMP_PATH"
        mkdir -p "$SEMAPHORE_TMP_PATH"
    fi

    # Try to create/modify a file using the Semaphore user
    if ! gosu semaphore touch "${SEMAPHORE_TMP_PATH}/.docker-entrypoint-probe" 2> /dev/null ; then
        _msg "Fixing permissions for $SEMAPHORE_TMP_PATH"

        if ! chown -R -h -c "semaphore:semaphore" "$SEMAPHORE_TMP_PATH" ; then
            _msg "Fatal: could not set ownership for directory '$SEMAPHORE_TMP_PATH'; aborting entrypoint" >&2
            exit 1
        fi
    fi
}

case "$1" in
    semaphore)
        if [[ "$2" == "runner" && "$3" == "start" ]] ; then
            configure_ssh_client
            set_files_ownership
        fi

        _msg "Running: $*"
        exec gosu semaphore "$@"
    ;;
esac


exec "$@"
