#!/usr/bin/env bash
#
# hashibackup.sh
#
##

# shellcheck disable=SC2174

set -o pipefail

: "${HB_CONFIG_FILE:="/etc/hashibackup.env"}"

readonly SCRIPT_NAME="hashibackup"
readonly SCRIPT_VERSION="0.2.0"


function _msg()
{
    echo "[$( date --utc -Iseconds )] $*" >&2
}

function _run()
{
    _msg "+ $*"
    "$@"
}

function log_info()
{
    _msg "[INFO] $*"
}

function log_warn()
{
    _msg "[WARN] $*"
}

function log_error()
{
    _msg "[EROR] $*"
}

function log_debug()
{
    [[ -n "$DEBUG" ]] && _msg "[DEBG] $*"
}

function check_dependencies()
{
    local -r commads=( consul nomad )
    local cmd
    local error=0

    log_debug "Checking required commands"

    for cmd in "${commads[@]}" ; do
        if ! command -v "$cmd" > /dev/null ; then
            log_error "Command not found: $cmd"
            error=1
        fi
    done

    if [[ $error -ne 0 ]] ; then
        log_error "One or more errors were found; aborting"
        exit 3
    fi
}

function load_config()
{
    # shellcheck source=/dev/null
    if [[ ! -f "$HB_CONFIG_FILE" ]] ; then
        log_info "Config file not found, using default configuration"
    elif ! . "$HB_CONFIG_FILE" ; then
        log_warn "Could not load config file, using default configuration"
    fi

    # Script configuration
    : "${HB_PRODUCTS:=""}"
    : "${HB_DATA_DIR:="/var/hashibackup"}"
    : "${HB_ENABLE_RETENTION_POLICY:="false"}"
    : "${HB_KEEP_LAST:="60"}"

    CONSUL_BACKUP_DIR="${HB_DATA_DIR}/consul"
    NOMAD_BACKUP_DIR="${HB_DATA_DIR}/nomad"

    # Export required variables
    export CONSUL_HTTP_ADDR
    export CONSUL_HTTP_TOKEN
    export NOMAD_ADDR
    export NOMAD_TOKEN
}

function create_backup_dirs()
{
    local backup_dir

    log_info "Creating backup directories"

    for backup_dir in \
        "$CONSUL_BACKUP_DIR" \
        "$NOMAD_BACKUP_DIR"
    do
        if ! _run mkdir -p -m 700 "$backup_dir" ; then
            log_error "Could not create backup directory '$backup_dir'; aborting"
            exit 4
        fi
    done
}

function create_consul_snapshot()
{
    if ! grep -q 'consul' <<< "$HB_PRODUCTS" ; then
        log_info "Consul is not enabled in HB_PRODUCTS; skipping"
        return 0
    fi

    local -r snapshot_file="${CONSUL_BACKUP_DIR}/$( date --utc +'%Y%m%d-%H%M%S' ).snap"

    log_info "Creating Consul snapshot"

    if ! _run consul snapshot save "$snapshot_file" ; then
        log_error "Could not save Consul snapshot"
        exit 1
    fi

    log_info "Snapshot successfully created!"
}

function create_nomad_snapshot()
{
    if ! grep -q 'nomad' <<< "$HB_PRODUCTS" ; then
        log_info "Nomad is not enabled in HB_PRODUCTS; skipping"
        return 0
    fi

    local -r snapshot_file="${NOMAD_BACKUP_DIR}/$( date --utc +'%Y%m%d-%H%M%S' ).snap"

    log_info "Creating Nomad snapshot"

    if ! _run nomad operator snapshot save "$snapshot_file" ; then
        log_error "Could not save Nomad snapshot"
        exit 1
    fi

    log_info "Snapshot successfully created!"
}

function run_retention_policy()
{
    if [[ ! "$HB_ENABLE_RETENTION_POLICY" =~ ^(true|yes|1)$ ]] ; then
        log_info "Retention policy is disabled, skipping removal of old backups"
        return 0
    fi

    local target_dir

    log_info "Removing old backups (keeping last $HB_KEEP_LAST files)"

    for target_dir in \
        "$CONSUL_BACKUP_DIR" \
        "$NOMAD_BACKUP_DIR"
    do
        # List backup files by modification time, exclude the HB_KEEP_LAST most recent files
        # from the list, then remove the remaining files
        if ! find "$target_dir" -type f -printf '%TY-%Tm-%TdT%TT %p\n' \
            | sort --reverse \
            | tail -n +"$(( HB_KEEP_LAST + 1 ))" \
            | awk '{ print $2 }' \
            | xargs -I '{}' rm -f -v -- '{}'
        then
            log_error "Error removing old backup files; see output for details"
            return 1
        fi
    done

    log_info "Old backup files successfully removed!"
}

function main()
{
    log_info "Running $SCRIPT_NAME v$SCRIPT_VERSION"

    check_dependencies
    load_config

    create_backup_dirs

    create_consul_snapshot
    create_nomad_snapshot

    run_retention_policy

    log_info "Program finished"
}


main "$@"
