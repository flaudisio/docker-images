#!/usr/bin/env bash

set -e
set -o pipefail

: "${CONFIG_DIR:="/etc/semaphore"}"
: "${SSH_LOG_LEVEL:="ERROR"}"

: "${SEMAPHORE_TMP_PATH:="/tmp/semaphore"}"
: "${SEMAPHORE_RUNNER_TOKEN_FILE:="${CONFIG_DIR}/runner.token"}"
: "${SEMAPHORE_RUNNER_PRIVATE_KEY_FILE:="${CONFIG_DIR}/runner.key"}"

# Required by Semaphore
export SEMAPHORE_TMP_PATH
export SEMAPHORE_RUNNER_TOKEN_FILE
export SEMAPHORE_RUNNER_PRIVATE_KEY_FILE


function _msg()
{
    echo "$( date +'%Y-%m-%d %T %Z' ) [entrypoint] $*" >&2
}

function setup_ssh_client()
{
    _msg "Configuring SSH client"

    if ! grep -q 'entrypoint.sh' /etc/ssh/ssh_config ; then
        printf "# entrypoint.sh\nHost *\n  LogLevel %s\n" "$SSH_LOG_LEVEL" >> /etc/ssh/ssh_config
    fi
}

function setup_semaphore_files()
{
    local -r error=0
    local -r required_dirs=(
        "$CONFIG_DIR"
        "$SEMAPHORE_TMP_PATH"
    )
    local -r required_files=(
        "$SEMAPHORE_RUNNER_TOKEN_FILE"
        "$SEMAPHORE_RUNNER_PRIVATE_KEY_FILE"
    )
    local path

    for path in "${required_dirs[@]}" ; do
        if [[ ! -d "$path" ]] ; then
            _msg "Creating $path"
            mkdir -p "$path"
        fi
    done

    for path in "${required_dirs[@]}" "${required_files[@]}" ; do
        if ! gosu semaphore touch "$path" 2> /dev/null ; then
            _msg "Fixing $path permissions"

            if ! chown -R -h -c "semaphore:semaphore" -- "$path" ; then
                _msg "Fatal: could not set ownership of $path" >&2
                error=1
            fi
        fi
    done

    [[ $error -eq 0 ]] || exit 1
}

function register_runner()
{
    if [[ -n "$SEMAPHORE_RUNNER_TOKEN" ]] ; then
        _msg "Variable SEMAPHORE_RUNNER_TOKEN is defined, skipping runner registration"
        return 0
    fi

    if [[ -n "$SEMAPHORE_RUNNER_REGISTRATION_TOKEN" ]] ; then
        _msg "Registering Semaphore Runner"

        echo -n "$SEMAPHORE_RUNNER_REGISTRATION_TOKEN" \
            | semaphore runner register --stdin-registration-token --no-config
    fi
}

case "$1" in
    semaphore)
        if [[ "$2" == "runner" && "$3" == "start" ]] ; then
            setup_ssh_client
            setup_semaphore_files
            register_runner
        fi

        _msg "Running: $*"
        exec gosu semaphore "$@"
    ;;
esac


exec "$@"
