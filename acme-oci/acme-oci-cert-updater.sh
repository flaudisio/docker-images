#!/usr/bin/env bash

set -o pipefail

# ------------------------------------------------------------------------------
# VARIABLES
# ------------------------------------------------------------------------------

readonly ProgramName="acme-oci-cert-updater"
readonly ProgramVersion="0.2.0"

readonly DefinedTagsFile="/tmp/defined-tags.json"

: "${SKIP_OCI_CERT_CREATION:=""}"
: "${SKIP_OCI_CERT_UPDATE:=""}"

: "${OCI_COMPARTMENT_ID:=""}"
: "${OCI_CERT_NAME:=""}"

: "${OCI_TAG_COMPONENT_REPO:="UNDEFINED"}"
: "${OCI_TAG_COMPONENT_PATH:="UNDEFINED"}"
: "${OCI_TAG_CREATED_BY:="$ProgramName"}"
: "${OCI_TAG_ENVIRONMENT:="UNDEFINED"}"
: "${OCI_TAG_OWNER:="UNDEFINED"}"
: "${OCI_TAG_SERVICE_NAME:="$ProgramName"}"

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

function create_oci_defined_tags_file()
{
    log_info "Creating OCI defined tags file"

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

function _create_oci_certificate()
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
            --name "$OCI_CERT_NAME" \
            "$@" \
            | jq -r '.data.id'
    )"
    then
        log_error "Could not create certificate; aborting"
        exit 1
    fi

    log_info "Successfully created certificate '$cert_id'!"
}

function _update_oci_certificate()
{
    if [[ -n "$SKIP_OCI_CERT_UPDATE" ]] ; then
        log_info "Variable SKIP_OCI_CERT_UPDATE is defined; skipping OCI certificate update"
        return 0
    fi

    local -r cert_id="$1"

    # Remaining arguments are forwarded to OCI CLI
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

function manage_oci_certificate()
{
    local cert_pem
    local chain_pem
    local privkey_pem
    local cert_id
    local oci_cli_args

    if [[ -n "$SKIP_OCI_CERT_CREATION" && -n "$SKIP_OCI_CERT_UPDATE" ]] ; then
        log_info "Variables SKIP_OCI_CERT_CREATION and SKIP_OCI_CERT_UPDATE are defined; aborting OCI certificate management"
        return 0
    fi

    # LEGO_CERT_PATH='lego-data/certificates/_.example.com.crt'
    # LEGO_CERT_PEM_PATH='lego-data/certificates/_.example.com.pem'
    # LEGO_CERT_KEY_PATH='lego-data/certificates/_.example.com.key'
    cert_pem="$( cat "$LEGO_CERT_PATH" )"
    chain_pem="$( cat "${LEGO_CERT_PATH/.crt/.issuer.crt}" )"
    privkey_pem="$( cat "$LEGO_CERT_KEY_PATH" )"

    if [[ -z "$cert_pem" || -z "$chain_pem" || -z "$privkey_pem" ]] ; then
        log_error "One or more required PEM files are empty or were not found; aborting OCI certificate management"
        return 1
    fi

    log_info "Searching for the OCI certificate ID..."

    if ! cert_id="$(
        _run oci certs-mgmt certificate list --all --compartment-id "$OCI_COMPARTMENT_ID" --name "$OCI_CERT_NAME" \
            | jq -r '.data.items[] | select(."lifecycle-state" == "ACTIVE") | .id'
    )"
    then
        log_error "Could not search for the certificate ID; aborting OCI certificate management"
        return 1
    fi

    oci_cli_args=(
        --description "Managed by $ProgramName"
        --defined-tags "file://${DefinedTagsFile}"
        --certificate-pem "$cert_pem"
        --cert-chain-pem "$chain_pem"
        --private-key-pem "$privkey_pem"
    )

    if [[ -z "$cert_id" ]] ; then
        _create_oci_certificate "${oci_cli_args[@]}"
    else
        _update_oci_certificate "$cert_id" "${oci_cli_args[@]}"
    fi
}

function main()
{
    log_info "Running $ProgramName v$ProgramVersion"

    check_required_vars \
        OCI_COMPARTMENT_ID \
        OCI_CERT_NAME \
        OCI_TAG_COMPONENT_REPO \
        OCI_TAG_COMPONENT_PATH \
        OCI_TAG_CREATED_BY \
        OCI_TAG_ENVIRONMENT \
        OCI_TAG_OWNER \
        OCI_TAG_SERVICE_NAME \
        LEGO_CERT_PATH \
        LEGO_CERT_KEY_PATH

    create_oci_defined_tags_file
    manage_oci_certificate

    log_info "Program finished"
}


main "$@"
