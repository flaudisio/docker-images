#!/bin/sh

# shellcheck shell=dash

set -e
set -o pipefail

CRON_USER="$( id -u -n )"
CRON_FILE="/tmp/crontab"


msg()
{
    echo "$( date +'%Y-%m-%d %T %Z' ) [entrypoint] $*" >&2
}

generate_crontab()
{
    msg "Generating file '$CRON_FILE'"

    cat <<EOF > "$CRON_FILE"
SHELL=/bin/sh
$CRON_SCHEDULE acme-oci
EOF
}


case "$1" in
    acme-oci)
        if [ "$2" = "--cron" ] ; then
            msg "Note: cron mode enabled (--cron)"
            generate_crontab

            msg "Running go-crond"
            exec go-crond "${CRON_USER}:${CRON_FILE}"
        fi
    ;;
esac


exec "$@"
