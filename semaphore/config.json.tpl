{
  "mysql": {
    "host": "",
    "user": "",
    "pass": "",
    "name": "",
    "options": null
  },
  "bolt": {
    "host": "",
    "user": "",
    "pass": "",
    "name": "",
    "options": null
  },
  "postgres": {
    "host": "${SEMAPHORE_DB_HOST}",
    "user": "${SEMAPHORE_DB_USER}",
    "pass": "${SEMAPHORE_DB_PASS}",
    "name": "${SEMAPHORE_DB_NAME}",
    "options": {
      "sslmode": "disable"
    }
  },
  "dialect": "${SEMAPHORE_DB_DIALECT}",
  "port": "${SEMAPHORE_PORT}",
  "interface": "${SEMAPHORE_INTERFACE}",
  "git_client": "${SEMAPHORE_GIT_CLIENT}",
  "tmp_path": "${SEMAPHORE_TMP_PATH}",
  "cookie_hash": "${SEMAPHORE_COOKIE_HASH}",
  "cookie_encryption": "${SEMAPHORE_COOKIE_ENCRYPTION}",
  "access_key_encryption": "${SEMAPHORE_ACCESS_KEY_ENCRYPTION}",
  "email_sender": "${SEMAPHORE_EMAIL_SENDER}",
  "email_host": "${SEMAPHORE_EMAIL_HOST}",
  "email_port": "${SEMAPHORE_EMAIL_PORT}",
  "email_username": "${SEMAPHORE_EMAIL_USERNAME}",
  "email_password": "${SEMAPHORE_EMAIL_PASSWORD}",
  "web_host": "${SEMAPHORE_WEB_ROOT}",
  "ldap_binddn": "${SEMAPHORE_LDAP_BINDDN}",
  "ldap_bindpassword": "${SEMAPHORE_LDAP_BINDPASSWORD}",
  "ldap_server": "${SEMAPHORE_LDAP_SERVER}",
  "ldap_searchdn": "${SEMAPHORE_LDAP_SEARCHDN}",
  "ldap_searchfilter": "${SEMAPHORE_LDAP_SEARCHFILTER}",
  "ldap_mappings": {
    "dn": "${SEMAPHORE_LDAP_DN}",
    "mail": "${SEMAPHORE_LDAP_MAIL}",
    "uid": "${SEMAPHORE_LDAP_UID}",
    "cn": "${SEMAPHORE_LDAP_CN}"
  },
  "telegram_chat": "${SEMAPHORE_TELEGRAM_CHAT}",
  "telegram_token": "${SEMAPHORE_TELEGRAM_TOKEN}",
  "slack_url": "${SEMAPHORE_SLACK_URL}",
  "concurrency_mode": "${SEMAPHORE_CONCURRENCY_MODE}",
  "max_parallel_tasks": ${SEMAPHORE_MAX_PARALLEL_TASKS},
  "email_alert": ${SEMAPHORE_EMAIL_ALERT},
  "email_secure": ${SEMAPHORE_EMAIL_SECURE},
  "telegram_alert": ${SEMAPHORE_TELEGRAM_ALERT},
  "slack_alert": ${SEMAPHORE_SLACK_ALERT},
  "ldap_enable": ${SEMAPHORE_LDAP_ENABLE},
  "ldap_needtls": ${SEMAPHORE_LDAP_NEEDTLS},
  "ssh_config_path": "${SEMAPHORE_SSH_CONFIG_PATH}",
  "demo_mode": ${SEMAPHORE_DEMO_MODE}
}
