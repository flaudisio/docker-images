#!/usr/bin/env bash

set -o pipefail

# ------------------------------------------------------------------------------
# VARIABLES
# ------------------------------------------------------------------------------

readonly ProgramName="acme-oci"
readonly ProgramVersion="0.2.0"

: "${HOOK_CMD:="${PWD}/acme-oci-cert-updater.sh"}"

: "${OCI_CERT_BASENAME:=""}"
: "${OCI_BACKUP_BUCKET_NAME:=""}"

: "${CLOUDFLARE_DNS_API_TOKEN:=""}"

: "${CERT_STAGING:=""}"
: "${CERT_DOMAINS:=""}"
: "${CERT_EMAIL:=""}"

: "${DATA_DIR:="lego-data"}"

# ------------------------------------------------------------------------------
# COMMON FUNCTIONS
# ------------------------------------------------------------------------------

function _msg()
{
    echo -e "[$( date --utc -Iseconds )] $*" >&2
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

function check_required_vars()
{
    local -r required_vars=( "$@" )
    local var_name
    local error=0

    log_info "Checking required variables"

    for var_name in "${required_vars[@]}" ; do
        if [[ -z "${!var_name}" ]] ; then
            log_error "You must set the ${var_name} variable"
            error=1
        fi
    done

    [[ $error -ne 0 ]] && exit 2
}

function _run()
{
    log_info "+ $*"
    "$@"
}

# ------------------------------------------------------------------------------
# SCRIPT FUNCTIONS
# ------------------------------------------------------------------------------

function prepare_data_dir()
{
    log_info "Preparing data directory '$DATA_DIR'"

    _run rm -rf -- "$DATA_DIR"

    if ! _run mkdir -p -m 700 "$DATA_DIR" ; then
        log_warn "Error creating directory; see the output for details"
        exit 1
    fi
}

function download_data_files_from_bucket()
{
    local -r bucket_file="${OCI_CERT_NAME}.tar.gz"
    local -r temp_file="/tmp/acme-download-${OCI_CERT_NAME}.$( date +'%Y%m%d-%H%M%S' ).tar.gz"

    log_info "Downloading file '$bucket_file' from bucket '$OCI_BACKUP_BUCKET_NAME'"

    if ! _run oci os object get --bucket-name "$OCI_BACKUP_BUCKET_NAME" --name "$bucket_file" --file "$temp_file" ; then
        log_warn "Could not download backup file; see output for details"
        return 1
    fi

    log_info "Extracting file '$temp_file'"

    if ! _run tar -x -z -f "$temp_file" -C "$DATA_DIR" ; then
        log_warn "Error extracting backup file; see the output for details"
        return 1
    fi

    log_info "Removing temporary file '$temp_file'"
    _run rm -f "$temp_file"
}

function upload_data_files_to_bucket()
{
    local -r bucket_file="${OCI_CERT_NAME}.tar.gz"
    local -r temp_file="/tmp/acme-upload-${OCI_CERT_NAME}.$( date +'%Y%m%d-%H%M%S' ).tar.gz"

    log_info "Creating archive '$temp_file'"

    if ! (
        _run cd "$DATA_DIR" || exit 1
        _run tar -c -z -f "$temp_file" -- * || exit 1
    )
    then
        log_warn "Error creating archive; skipping upload to bucket!"
        return 0
    fi

    log_info "Uploading file '$temp_file' to bucket '$OCI_BACKUP_BUCKET_NAME'"

    if ! _run oci os object put --force --bucket-name "$OCI_BACKUP_BUCKET_NAME" --name "$bucket_file" --file "$temp_file" ; then
        log_warn "Error uploading to bucket. It won't be restored in future runs!"
    fi
}

function request_certificate()
{
    local -r hook_cmd="$1"
    local domains
    local domain
    local primary_domain
    local lego_names
    local lego_opts=()

    IFS=',' read -r -a domains <<< "$CERT_DOMAINS"

    for domain in "${domains[@]}" ; do
        lego_opts+=( --domains "$domain" )
    done

    # The first domain is used by Lego as the certificate identifier
    primary_domain="${domains[0]}"

    log_info "Listing existing certificate common names"

    if ! lego_names="$( _run lego list --names )" ; then
        log_error "Error running Lego CLI; aborting"
        exit 1
    fi

    # Use 'sort' to normalize the list and '-x' to match the entire line
    if echo "$lego_names" | sort | grep -q -F -x "$primary_domain" ; then
        log_info "Renewing certificate for '$primary_domain'"
        lego_opts+=( renew --no-bundle --renew-hook "$hook_cmd" )
    else
        log_info "Domain '$primary_domain' not found, requesting new certificate"
        lego_opts+=( run --no-bundle --run-hook "$hook_cmd" )
    fi

    if ! _run lego --accept-tos --email "$CERT_EMAIL" --dns "cloudflare" "${lego_opts[@]}" ; then
        log_error "Error running Lego CLI; aborting"
        exit 1
    fi
}

function main()
{
    log_info "Running $ProgramName v$ProgramVersion"

    check_required_vars \
        HOOK_CMD \
        OCI_CERT_BASENAME \
        OCI_BACKUP_BUCKET_NAME \
        CLOUDFLARE_DNS_API_TOKEN \
        CERT_DOMAINS \
        CERT_EMAIL

    # Configuration for Lego CLI
    LEGO_PATH="${DATA_DIR}/production"
    LEGO_SERVER="https://acme-v02.api.letsencrypt.org/directory"

    # Configuration for this script and the hook script
    OCI_CERT_NAME="${OCI_CERT_BASENAME}-production"

    if [[ "$CERT_STAGING" =~ ^(true|yes|1)$ ]] ; then
        log_warn "Using Let's Encrypt staging environment"

        LEGO_PATH="${DATA_DIR}/staging"
        LEGO_SERVER="https://acme-staging-v02.api.letsencrypt.org/directory"
        OCI_CERT_NAME="${OCI_CERT_BASENAME}-staging"
    fi

    export LEGO_PATH
    export LEGO_SERVER
    export OCI_CERT_NAME

    log_debug "PWD           = $PWD"
    log_debug "DATA_DIR      = $DATA_DIR"
    log_debug "LEGO_PATH     = $LEGO_PATH"
    log_debug "LEGO_SERVER   = $LEGO_SERVER"
    log_debug "OCI_CERT_NAME = $OCI_CERT_NAME"

    prepare_data_dir
    download_data_files_from_bucket
    request_certificate "$HOOK_CMD"
    upload_data_files_to_bucket

    log_info "Program finished"
}


main "$@"
