#!/bin/sh

# shellcheck shell=dash

set -e
set -o pipefail


msg()
{
    echo "[entrypoint] $*" >&2
}

set_files_ownership()
{
    local data_dir

    for data_dir in \
        "$BASEDIR" \
        "$TEMP_PATH"
    do
        if [ ! -d "$data_dir" ] ; then
            msg "[INFO] Creating $data_dir"
            mkdir -p "$data_dir"
        fi

        # Try to create/modify a file using the transfer.sh user
        if ! gosu "$TRANSFER_USER" touch "${data_dir}/.docker-entrypoint-probe" 2> /dev/null ; then
            msg "[INFO] Fixing permissions for $data_dir"

            if ! chown -R "$TRANSFER_USER" "$data_dir" ; then
                msg "[ERROR] Could not fix $data_dir permissions; please check your environment. Aborting Docker entrypoint" >&2
                exit 1
            fi
        fi
    done
}

case "$1" in
    transfer)
        set_files_ownership

        msg "[INFO] Running transfer.sh"
        exec gosu "$TRANSFER_USER" "$@"
    ;;
esac

exec "$@"
