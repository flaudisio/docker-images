#!/bin/sh
#
# prepare-ci.sh
# CI/CD bootstrapping script
#
# See function 'check_required_vars()' for the required environment variables.
#
##

set -e

: ${K8S_DEPLOY_USER:=ci-deploys}
: ${KUBECONFIG:=/etc/kube-config}

export K8S_DEPLOY_USER
export KUBECONFIG


check_required_vars()
{
    local required_var

    echo -n "Checking required environment variables... "

    for required_var in \
        K8S_CLUSTER_SERVER \
        K8S_CLIENT_CRT \
        K8S_CLIENT_KEY
    do
        if [ -z "$( eval "echo \$$required_var" )" ] ; then
            echo "FATAL: variable $required_var is not set. Aborting." >&2
            exit 1
        fi
    done

    echo "OK"
}

create_kubeconfig()
{
    echo -n "Creating kube config file '$KUBECONFIG'... "

    cat /etc/kube-config.tmpl | envsubst > "$KUBECONFIG"

    echo "OK"
}

main()
{
    set +x
    check_required_vars

    set -x
    create_kubeconfig
}

main
