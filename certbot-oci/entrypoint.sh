#!/bin/sh

# shellcheck shell=dash

set -e
set -o pipefail

: "${SECRETS_DIR:="/secrets"}"

CronUser="$( id -u -n )"
CrontabFile="/tmp/crontab"


msg()
{
    echo "$( date +'%Y-%m-%d %T %Z' ) [entrypoint] $*" >&2
}

load_secrets()
{
    local file

    for file in "${SECRETS_DIR}"/* ; do
        if [ ! -f "$file" ] ; then
            continue
        fi

        msg "Loading secrets from file '$file'"

        # shellcheck source=/dev/null
        . "$file"
    done
}

generate_crontab()
{
    msg "Generating file '$CrontabFile'"

    if ! printf "SHELL=/bin/sh\n%s certbot-oci\n" "$SCHEDULE" > "$CrontabFile" ; then
        msg "Error: could not create crontab file"
        exit 1
    fi
}


case $1 in
    certbot-oci)
        load_secrets

        if [ "$2" = "--cron" ] ; then
            msg "Note: cron mode enabled (--cron)"
            generate_crontab

            msg "Running go-crond"
            exec go-crond "${CronUser}:${CrontabFile}"
        fi
    ;;
esac


exec "$@"
