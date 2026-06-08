#!/usr/bin/env bash

set -e
set -o pipefail

: "${CONFIG_DIR:="/etc/semaphore"}"
: "${SSH_LOG_LEVEL:="ERROR"}"

: "${SEMAPHORE_CLI_EXTRA_ARGS:=""}"
: "${SEMAPHORE_TMP_PATH:="/tmp/semaphore"}"

export SEMAPHORE_TMP_PATH


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

function setup_semaphore_dirs()
{
    local -r semaphore_dirs=(
        "$CONFIG_DIR"
        "$SEMAPHORE_TMP_PATH"
    )
    local path
    local error=0

    for path in "${semaphore_dirs[@]}" ; do
        if [[ ! -d "$path" ]] ; then
            _msg "Creating $path"
            mkdir -p "$path"
        fi
    done

    for path in "${semaphore_dirs[@]}" ; do
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

function setup_admin_user()
{
    if [[ -z "$SEMAPHORE_ADMIN" ]] ; then
        _msg "Skipping admin user setup because variable SEMAPHORE_ADMIN is not defined"
        return
    fi

    _msg "Configuring admin user"

    local user_cmd="add"

    if semaphore --no-config user list | grep -q "^${SEMAPHORE_ADMIN}\$" ; then
        user_cmd="change-by-login"
    fi

    semaphore user "$user_cmd" \
        --no-config \
        --admin \
        --login "$SEMAPHORE_ADMIN" \
        --name "$SEMAPHORE_ADMIN_NAME" \
        --email "$SEMAPHORE_ADMIN_EMAIL" \
        --password "$SEMAPHORE_ADMIN_PASSWORD"
}

function register_runner()
{
    if [[ -z "$SEMAPHORE_RUNNER_REGISTRATION_TOKEN" ]] ; then
        _msg "Variable SEMAPHORE_RUNNER_REGISTRATION_TOKEN is not defined, skipping runner registration"
        return 0
    fi

    : "${SEMAPHORE_RUNNER_TOKEN_FILE:="${CONFIG_DIR}/runner.token"}"
    : "${SEMAPHORE_RUNNER_PRIVATE_KEY_FILE:="${CONFIG_DIR}/runner.key"}"

    export SEMAPHORE_RUNNER_TOKEN_FILE
    export SEMAPHORE_RUNNER_PRIVATE_KEY_FILE

    if [[ -s "$SEMAPHORE_RUNNER_TOKEN_FILE" && -s "$SEMAPHORE_RUNNER_PRIVATE_KEY_FILE" ]] ; then
        _msg "Found runner token and private key files, skipping runner registration"
        return 0
    fi

    _msg "Registering Semaphore Runner"

    echo -n "$SEMAPHORE_RUNNER_REGISTRATION_TOKEN" \
        | semaphore runner register --stdin-registration-token --no-config

    _msg "Runner successfully registered!"
    _msg "NOTE: to ENABLE the runner, go to ${SEMAPHORE_WEB_ROOT}/runners"
}

function main()
{
    local cmd=( "$@" )
    local sanitized_cli_args=()

    case "$1" in
        semaphore)
            if [[ "$2" == "server" ]] ; then
                setup_semaphore_dirs
                setup_admin_user
            fi

            if [[ "$2" == "runner" && "$3" == "start" ]] ; then
                setup_semaphore_dirs
                setup_ssh_client
                register_runner
            fi

            read -r -a sanitized_cli_args <<< "$SEMAPHORE_CLI_EXTRA_ARGS"

            cmd+=( "${sanitized_cli_args[@]}" )

            _msg "+ ${cmd[*]}"
            exec gosu semaphore "${cmd[@]}"
        ;;
    esac

    exec "${cmd[@]}"
}


main "$@"
