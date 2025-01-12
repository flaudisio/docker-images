#!/bin/sh

# shellcheck shell=ash

set -e
set -o pipefail

_msg()
{
    echo "$( date +'%Y-%m-%d %T %Z' ) [entrypoint] $*" >&2
}

configure_admin_user()
{
    if [ -z "$SEMAPHORE_ADMIN" ] ; then
        _msg "Skipping admin user setup because variable SEMAPHORE_ADMIN is not defined"
        return
    fi

    _msg "Configuring admin user"

    local user_cmd="add"

    if semaphore --no-config user list | grep -q "^${SEMAPHORE_ADMIN}\$" ; then
        user_cmd="change-by-login"
    fi

    semaphore --no-config user "$user_cmd" \
        --admin \
        --login "$SEMAPHORE_ADMIN" \
        --name "$SEMAPHORE_ADMIN_NAME" \
        --email "$SEMAPHORE_ADMIN_EMAIL" \
        --password "$SEMAPHORE_ADMIN_PASSWORD"
}

case "$1" in
    semaphore)
        if [ "$2" = "server" ] ; then
            configure_admin_user
        fi

        _msg "Running: $*"
        exec gosu semaphore "$@"
    ;;
esac

exec "$@"
