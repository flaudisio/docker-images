#!/usr/bin/env bash
#
# certbot-oci
#
# Script to manage Let's Encrypt certificates using Certbot + Cloudflare DNS authenticator.
# Generated certificates are (optionally) saved on an OCI bucket and (also optionally) configured
# in the specified OCI certificate.
#
# Requirements:
# - certbot-dns-cloudflare 2.x
# - oci-cli 3.x
#
# Directory structure:
#
# workspace/  --> WORKSPACE
#     b026324c6904b2a9cb4b88d6d61c81d1/  --> BASEDIR
#         production/  --> CERTS_DIR
#             config/
#                 live/
#             logs/
#         staging/     --> CERTS_DIR
#             config/
#             logs/
#
# ------------------------------------------------------------------------------
# !!! IMPORTANT !!!
#
# The directory structure must be *as stable as possible* to avoid breaking the
# Certbot's certificate renewal process, as it uses absolute paths in the
# 'config/renewal/*.conf' files.
# ------------------------------------------------------------------------------
#
##

# shellcheck disable=SC2174

set -o pipefail

readonly ProgramName="certbot-oci"
readonly ProgramVersion="0.3.0"

readonly CloudflareCredentialsFile="/tmp/cloudflare-credentials.ini"
readonly DefinedTagsFile="/tmp/defined-tags.json"

: "${DEBUG:=""}"
: "${SKIP_OCI_CERT_CREATION:=""}"
: "${SKIP_OCI_CERT_UPDATE:=""}"

# NOTE: avoid changing WORKSPACE to not break references in Certbot's config/renewal/*.conf files
: "${WORKSPACE:="/tmp/certbot-oci"}"

: "${CLOUDFLARE_API_TOKEN:=""}"

: "${CERTBOT_STAGING:=""}"
: "${CERTBOT_DOMAINS:=""}"
: "${CERTBOT_EMAIL:=""}"
: "${CERTBOT_CLOUDFLARE_PROPAGATION_SECONDS:="30"}"

: "${OCI_COMPARTMENT_ID:=""}"
: "${OCI_CERTIFICATE_NAME:=""}"
: "${OCI_BACKUP_BUCKET_NAME:=""}"

: "${OCI_TAG_COMPONENT_REPO:="UNDEFINED"}"
: "${OCI_TAG_COMPONENT_PATH:="UNDEFINED"}"
: "${OCI_TAG_CREATED_BY:="$ProgramName"}"
: "${OCI_TAG_ENVIRONMENT:="UNDEFINED"}"
: "${OCI_TAG_OWNER:="UNDEFINED"}"
: "${OCI_TAG_SERVICE_NAME:="$ProgramName"}"


_msg()
{
    echo -e "[$( date --utc -Iseconds )] $*" >&2
}

log_info()
{
    _msg "[INFO] $*"
}

log_warn()
{
    _msg "[WARN] $*"
}

log_error()
{
    _msg "[EROR] $*"
}

log_debug()
{
    [[ -n "$DEBUG" ]] && _msg "[DEBG] $*"
}

check_env()
{
    local -r commands=( jq certbot oci )
    local cmd
    local error=0

    log_debug "Checking required commands"

    for cmd in "${commands[@]}" ; do
        if ! command -v "$cmd" > /dev/null ; then
            log_error "Command not found: $cmd"
            error=1
        fi
    done

    local -r required_vars=(
        CERTBOT_DOMAINS
        CERTBOT_EMAIL
        CLOUDFLARE_API_TOKEN
        OCI_COMPARTMENT_ID
        OCI_CERTIFICATE_NAME
    )
    local var_name

    log_debug "Checking required environment variables"

    for var_name in "${required_vars[@]}" ; do
        log_debug "Checking $var_name"

        if [[ -z "${!var_name}" ]] ; then
            log_error "You must set the ${var_name} environment variable"
            error=1
        fi
    done

    if [[ $error -ne 0 ]] ; then
        log_error "One or more errors were found; aborting"
        exit 3
    fi
}

set_global_variables()
{
    local domains_md5sum
    local env_dir="production"

    log_debug "Setting global variables"

    # TODO: does it still make sense to use the md5 sum?
    if ! domains_md5sum="$( md5sum <<< "$OCI_CERTIFICATE_NAME" | cut -d ' ' -f 1 )" ; then
        log_error "Error calculating MD5 digest of OCI_CERTIFICATE_NAME variable; aborting"
        exit 1
    fi

    _is_certbot_staging && env_dir="staging"

    # Variables required by other script functions

    BASEDIR="${WORKSPACE}/${domains_md5sum}"
    CERTS_DIR="${BASEDIR}/${env_dir}"

    BACKUP_FILENAME="${domains_md5sum}.tar.gz"
}

create_basedir()
{
    log_info "Creating directory '$BASEDIR'"

    if ! mkdir -p -m 700 "$BASEDIR" > /dev/null ; then
        log_error "Could not create working directory; aborting"
        exit 4
    fi
}

restore_backup()
{
    if [[ -z "$OCI_BACKUP_BUCKET_NAME" ]] ; then
        log_info "Variable OCI_BACKUP_BUCKET_NAME is not defined; skipping restore"
        return 0
    fi

    local -r temp_file="/tmp/${ProgramName}-restore-$$.tar.gz"

    log_info "Downloading file '$BACKUP_FILENAME' from bucket '$OCI_BACKUP_BUCKET_NAME'"

    if ! oci os object get --bucket-name "$OCI_BACKUP_BUCKET_NAME" --name "$BACKUP_FILENAME" --file "$temp_file" ; then
        log_warn "WARNING: could not download backup file; see the 'oci' command output for details"
        return 0
    fi

    log_info "Extracting file '$temp_file'"

    if ! tar -xz -f "$temp_file" -C "$BASEDIR" ; then
        log_warn "WARNING: error extracting backup file; see the output for details"
    fi

    log_debug "Removing temporary file '$temp_file'"
    rm -f "$temp_file"
}

create_backup()
{
    if [[ -z "$OCI_BACKUP_BUCKET_NAME" ]] ; then
        log_info "Variable OCI_BACKUP_BUCKET_NAME is not defined; skipping upload"
        return 0
    fi

    local -r backup_file="/tmp/${ProgramName}-$( date +'%Y%m%d-%H%M%S' )-${BACKUP_FILENAME}"

    log_info "Creating archive '$backup_file'"

    if ! (
        cd "$BASEDIR" || exit 1
        tar -cz -f "$backup_file" -- * || exit 1
    )
    then
        log_warn "WARNING: error creating archive; skipping upload to bucket!"
        return 0
    fi

    log_info "Uploading file '$backup_file' to bucket '$OCI_BACKUP_BUCKET_NAME'"

    if ! oci os object put --force --bucket-name "$OCI_BACKUP_BUCKET_NAME" --name "$BACKUP_FILENAME" --file "$backup_file" ; then
        log_warn "WARNING: error uploading to bucket. It won't be restored in future runs!"
    fi
}

fix_basedir_permissions()
{
    log_info "Fixing user permissions for working directory"

    if ! chown -R "$( id -u ):$( id -g )" -- "$BASEDIR" ; then
        log_warn "WARNING: could not fix permissions; this may affect the certificate request process!"
        return 0
    fi
}

create_cloudflare_credentials_file()
{
    log_info "Creating Cloudflare credentials file '$CloudflareCredentialsFile'"

    if ! echo "dns_cloudflare_api_token = $CLOUDFLARE_API_TOKEN" > "$CloudflareCredentialsFile" ; then
        log_error "Error creating file; aborting"
        exit 1
    fi

    if ! chmod 600 "$CloudflareCredentialsFile" ; then
        log_error "Error changing file permissions; aborting"
        exit 1
    fi
}

_is_certbot_staging()
{
    [[ "$CERTBOT_STAGING" =~ ^(true|yes|1)$ ]]
}

run_certbot()
{
    local -r config_dir="${CERTS_DIR}/config"
    local -r logs_dir="${CERTS_DIR}/logs"
    local -r work_dir="${CERTS_DIR}/work"

    log_info "Creating required directories"

    if ! mkdir -p -m 700 "$work_dir" "$logs_dir" "$config_dir" ; then
        log_error "Could not create directories; aborting"
        exit 1
    fi

    local certbot_args=()

    if _is_certbot_staging ; then
        certbot_args+=( --staging )
        log_warn "WARNING: using Let's Encrypt staging server (--staging)"
    fi

    log_info "Running Certbot to request/renew certificate"

    if ! certbot certonly --non-interactive --agree-tos "${certbot_args[@]}" \
        --cert-name "$OCI_CERTIFICATE_NAME" \
        --domain "$CERTBOT_DOMAINS" \
        --email "$CERTBOT_EMAIL" \
        --dns-cloudflare \
        --dns-cloudflare-credentials "$CloudflareCredentialsFile" \
        --dns-cloudflare-propagation-seconds "$CERTBOT_CLOUDFLARE_PROPAGATION_SECONDS" \
        --config-dir "$config_dir" \
        --logs-dir "$logs_dir" \
        --work-dir "$work_dir" \
        >&2
    then
        log_warn "WARNING: could not request/renew certificate. This may lead to problems in the next steps!"
        return 0
    fi
}

create_oci_defined_tags_file()
{
    log_debug "Creating OCI defined tags file"

    if ! jq -n \
        --arg "component_repo" "$OCI_TAG_COMPONENT_REPO" \
        --arg "component_path" "$OCI_TAG_COMPONENT_PATH" \
        --arg "created_by" "$OCI_TAG_CREATED_BY" \
        --arg "environment" "$OCI_TAG_ENVIRONMENT" \
        --arg "owner" "$OCI_TAG_OWNER" \
        --arg "service_name" "$OCI_TAG_SERVICE_NAME" \
        '{
          "iac": {
              "component-repo": $component_repo,
              "component-path": $component_path,
              "created-by": $created_by,
              "environment": $environment,
              "owner": $owner,
              "service-name": $service_name
          }
        }' > "$DefinedTagsFile"
    then
        log_error "Could not create defined tags file"
        exit 1
    fi
}

_create_oci_certificate()
{
    if [[ -n "$SKIP_OCI_CERT_CREATION" ]] ; then
        log_info "Variable SKIP_OCI_CERT_CREATION is defined; skipping OCI certificate creation"
        return 0
    fi

    log_info "Creating OCI certificate"

    local cert_id

    if ! cert_id="$(
        oci certs-mgmt certificate create-by-importing-config \
            --compartment-id "$OCI_COMPARTMENT_ID" \
            --name "$OCI_CERTIFICATE_NAME" \
            "$@" \
            | jq -r '.data.id'
    )"
    then
        log_error "Could not create certificate; aborting"
        exit 1
    fi

    log_info "Successfully created certificate '$cert_id'!"
}

_update_oci_certificate()
{
    # TODO: add logic to skip certificate update if it was not renewed by Certbot
    if [[ -n "$SKIP_OCI_CERT_UPDATE" ]] ; then
        log_info "Variable SKIP_OCI_CERT_UPDATE is defined; skipping OCI certificate update"
        return 0
    fi

    local -r cert_id="$1"

    # Remaining arguments are passed on to OCI CLI
    shift

    log_info "Updating OCI certificate '$cert_id'"

    if ! oci certs-mgmt certificate update-certificate-by-importing-config-details \
        --force \
        --certificate-id "$cert_id" \
        "$@"
    then
        log_error "Could not update certificate; aborting"
        exit 1
    fi

    log_info "Successfully updated certificate!"
}

manage_oci_certificate()
{
    local pem_files_dir
    local cert_pem
    local chain_pem
    local privkey_pem
    local oci_cli_args
    local cert_id

    if [[ -n "$SKIP_OCI_CERT_CREATION" && -n "$SKIP_OCI_CERT_UPDATE" ]] ; then
        log_info "Variables SKIP_OCI_CERT_CREATION and SKIP_OCI_CERT_UPDATE are defined; skipping OCI certificate management"
        return 0
    fi

    log_info "Getting the PEM files directory"

    # Do the best to find the newest certificates directory; useful if Certbot duplicates it (e.g. 'example.com-0001')
    # shellcheck disable=SC2012
    if ! pem_files_dir="$(
        find "$CERTS_DIR" -type d -path '*/config/live/*' -exec stat -c '%Z %n' '{}' \; \
            | sort -n \
            | tail -n 1 \
            | awk '{ print $2 }'
    )"
    then
        log_error "Error obtaining the PEM files directory; aborting OCI certificate management"
        return 1
    fi

    if [[ ! -d "$pem_files_dir" ]] ; then
        log_error "The PEM files directory '$pem_files_dir' does not exist; aborting OCI certificate management"
        return 1
    fi

    log_info "Loading PEM files from directory '$pem_files_dir'"

    cert_pem="$( cat "${pem_files_dir}/cert.pem" )"
    chain_pem="$( cat "${pem_files_dir}/chain.pem" )"
    privkey_pem="$( cat "${pem_files_dir}/privkey.pem" )"

    if [[ -z "$cert_pem" || -z "$chain_pem" || -z "$privkey_pem" ]] ; then
        log_error "One or more required PEM files are empty or were not found; aborting OCI certificate management"
        return 1
    fi

    oci_cli_args=(
        --description "Managed by $ProgramName"
        --defined-tags "file://${DefinedTagsFile}"
        --certificate-pem "$cert_pem"
        --cert-chain-pem "$chain_pem"
        --private-key-pem "$privkey_pem"
    )

    log_info "Searching for the certificate ID..."

    if ! cert_id="$(
        oci certs-mgmt certificate list --all --compartment-id "$OCI_COMPARTMENT_ID" --name "$OCI_CERTIFICATE_NAME" \
            | jq -r '.data.items[] | select(."lifecycle-state" == "ACTIVE") | .id'
    )"
    then
        log_error "Could not search certificate ID; aborting OCI certificate management"
        return 1
    fi

    if [[ -z "$cert_id" ]] ; then
        _create_oci_certificate "${oci_cli_args[@]}"
    else
        # TODO: add logic to skip the OCI certificate update when Certbot didn't renew the certificate,
        # so a new version[1] is not created unnecessarily.
        #
        # [1] https://docs.oracle.com/en-us/iaas/Content/certificates/rotation-states.htm
        _update_oci_certificate "$cert_id" "${oci_cli_args[@]}"
    fi
}

main()
{
    log_info "Running $ProgramName v$ProgramVersion"

    check_env
    set_global_variables
    create_basedir

    restore_backup
    fix_basedir_permissions

    create_cloudflare_credentials_file
    run_certbot
    create_backup

    create_oci_defined_tags_file
    manage_oci_certificate

    log_info "Program finished"
}


main "$@"
