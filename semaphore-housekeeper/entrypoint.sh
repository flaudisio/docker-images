#!/bin/sh

# shellcheck shell=dash

set -e
set -o pipefail

User="$( id -u -n )"
CrontabFile="/tmp/crontab"


msg()
{
    echo "$( date +'%Y-%m-%d %T %Z' ) [entrypoint] $*" >&2
}

check_sanity()
{
    if [ ! -d "$SEMAPHORE_TMP_PATH" ] ; then
        msg "Error: directory '$SEMAPHORE_TMP_PATH' does not exist"
        exit 1
    fi
}

generate_crontab()
{
    msg "Generating $CrontabFile"

    if ! printf "SHELL=/bin/sh\n%s housekeeper\n" "$SCHEDULE" > "$CrontabFile" ; then
        msg "Error: could not create crontab file"
        exit 1
    fi
}


case $1 in
    run)
        check_sanity
        generate_crontab

        msg "Running go-crond"
        exec go-crond "${User}:${CrontabFile}"
    ;;
esac


exec "$@"
