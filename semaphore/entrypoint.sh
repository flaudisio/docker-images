#!/usr/bin/env bash

set -e
set -o pipefail

readonly SemaphoreConfigFile="${SEMAPHORE_CONFIG_PATH}/config.json"

: "${SECRETS_DIR:="/secrets"}"
: "${SSH_LOG_LEVEL:="ERROR"}"


msg()
{
    echo "$( date +'%Y-%m-%d %T %Z' ) [entrypoint] $*" >&2
}

load_secrets()
{
    local file

    for file in "${SECRETS_DIR}"/* ; do
        if [[ ! -f "$file" ]] ; then
            continue
        fi

        msg "[INFO] Loading secrets from file '$file'"

        # shellcheck source=/dev/null
        . "$file"
    done
}

fix_directory_permissions()
{
    local data_dir

    for data_dir in \
        "$SEMAPHORE_TMP_PATH" \
        "$SEMAPHORE_CONFIG_PATH" \
        "$SEMAPHORE_DB_PATH"
    do
        if [[ ! -d "$data_dir" ]] ; then
            msg "[INFO] Creating $data_dir"
            mkdir -p "$data_dir"
        fi

        # Try to create/modify a file using the Semaphore user
        if ! gosu "$SEMAPHORE_USER" touch "${data_dir}/.docker-entrypoint-probe" 2> /dev/null ; then
            msg "[INFO] Fixing permissions for $data_dir"

            if ! chown -R "$SEMAPHORE_USER" "$data_dir" ; then
                msg "[ERROR] Could not fix $data_dir permissions; please check your environment. Aborting Docker entrypoint" >&2
                exit 1
            fi
        fi
    done
}

configure_ssh_client()
{
    msg "[INFO] Configuring SSH client"

    if ! grep -q 'entrypoint.sh' /etc/ssh/ssh_config ; then
        printf "# entrypoint.sh\nHost *\n  LogLevel %s\n" "$SSH_LOG_LEVEL" >> /etc/ssh/ssh_config
    fi
}

generate_config_file()
{
    msg "[INFO] Setting default config values"

    export SEMAPHORE_WEB_ROOT="${SEMAPHORE_WEB_ROOT:-"http://localhost:3000"}"
    export SEMAPHORE_PORT="${SEMAPHORE_PORT:-""}"
    export SEMAPHORE_INTERFACE="${SEMAPHORE_INTERFACE:-""}"
    export SEMAPHORE_GIT_CLIENT="${SEMAPHORE_GIT_CLIENT:-""}"

    export SEMAPHORE_EMAIL_ALERT="${SEMAPHORE_EMAIL_ALERT:-"false"}"
    export SEMAPHORE_EMAIL_SECURE="${SEMAPHORE_EMAIL_SECURE:-"false"}"
    export SEMAPHORE_EMAIL_SENDER="${SEMAPHORE_EMAIL_SENDER:-""}"
    export SEMAPHORE_EMAIL_HOST="${SEMAPHORE_EMAIL_HOST:-""}"
    export SEMAPHORE_EMAIL_PORT="${SEMAPHORE_EMAIL_PORT:-""}"
    export SEMAPHORE_EMAIL_USERNAME="${SEMAPHORE_EMAIL_USERNAME:-""}"
    export SEMAPHORE_EMAIL_PASSWORD="${SEMAPHORE_EMAIL_PASSWORD:-""}"

    export SEMAPHORE_LDAP_ENABLE="${SEMAPHORE_LDAP_ENABLE:-"false"}"
    export SEMAPHORE_LDAP_NEEDTLS="${SEMAPHORE_LDAP_NEEDTLS:-"false"}"
    export SEMAPHORE_LDAP_BINDDN="${SEMAPHORE_LDAP_BINDDN:-""}"
    export SEMAPHORE_LDAP_BINDPASSWORD="${SEMAPHORE_LDAP_BINDPASSWORD:-""}"
    export SEMAPHORE_LDAP_SERVER="${SEMAPHORE_LDAP_SERVER:-""}"
    export SEMAPHORE_LDAP_SEARCHDN="${SEMAPHORE_LDAP_SEARCHDN:-""}"
    export SEMAPHORE_LDAP_SEARCHFILTER="${SEMAPHORE_LDAP_SEARCHFILTER:-""}"
    export SEMAPHORE_LDAP_DN="${SEMAPHORE_LDAP_DN:-""}"
    export SEMAPHORE_LDAP_MAIL="${SEMAPHORE_LDAP_MAIL:-""}"
    export SEMAPHORE_LDAP_UID="${SEMAPHORE_LDAP_UID:-""}"
    export SEMAPHORE_LDAP_CN="${SEMAPHORE_LDAP_CN:-""}"

    export SEMAPHORE_TELEGRAM_ALERT="${SEMAPHORE_TELEGRAM_ALERT:-"false"}"
    export SEMAPHORE_TELEGRAM_CHAT="${SEMAPHORE_TELEGRAM_CHAT:-""}"
    export SEMAPHORE_TELEGRAM_TOKEN="${SEMAPHORE_TELEGRAM_TOKEN:-""}"

    export SEMAPHORE_SLACK_ALERT="${SEMAPHORE_SLACK_ALERT:-"false"}"
    export SEMAPHORE_SLACK_URL="${SEMAPHORE_SLACK_URL:-""}"

    export SEMAPHORE_CONCURRENCY_MODE="${SEMAPHORE_CONCURRENCY_MODE:-""}"
    export SEMAPHORE_MAX_PARALLEL_TASKS="${SEMAPHORE_MAX_PARALLEL_TASKS:-"0"}"

    export SEMAPHORE_SSH_CONFIG_PATH="${SEMAPHORE_SSH_CONFIG_PATH:-""}"
    export SEMAPHORE_DEMO_MODE="${SEMAPHORE_DEMO_MODE:-"false"}"

    msg "[INFO] Generating config file"

    gosu "$SEMAPHORE_USER" sh -c "envsubst < /etc/config.json.tpl > '$SemaphoreConfigFile'"
}

configure_admin_user()
{
    local user_cmd="add"

    if semaphore --config "$SemaphoreConfigFile" user list | grep -q "^${SEMAPHORE_ADMIN}\$" ; then
        user_cmd="change-by-login"
    fi

    semaphore --config "$SemaphoreConfigFile" user "$user_cmd" \
        --admin \
        --login "$SEMAPHORE_ADMIN" \
        --name "$SEMAPHORE_ADMIN_NAME" \
        --email "$SEMAPHORE_ADMIN_EMAIL" \
        --password "$SEMAPHORE_ADMIN_PASSWORD"
}


case $1 in
    semaphore)
        load_secrets
        fix_directory_permissions
        configure_ssh_client
        generate_config_file

        if [[ "$2" == "server" ]] ; then
            msg "[INFO] Running migrations"
            gosu "$SEMAPHORE_USER" semaphore migrate --config "$SemaphoreConfigFile"

            msg "[INFO] Configuring admin user"
            configure_admin_user

            msg "[INFO] Running Semaphore server"
            exec gosu "$SEMAPHORE_USER" semaphore server --config "$SemaphoreConfigFile"
        fi

        exec gosu "$SEMAPHORE_USER" "$@"
    ;;
esac


exec "$@"
