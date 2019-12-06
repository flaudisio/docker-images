FROM docker:19

LABEL \
    maintainer="Flaudísio Tolentino <code+docker-images@flaudisio.com>" \
    com.flaudisio.image-type="base-image" \
    com.flaudisio.name="CI - K8s Deploys" \
    com.flaudisio.vcs-ref="https://github.com/flaudisio/docker-images"

ARG aws_cli_version="1.*"
ENV AWS_CLI_VERSION ${aws_cli_version}

RUN set -eux ; \
    apk add --no-cache \
        ca-certificates \
        gettext \
        jq \
        py3-pip ; \
    pip3 install -U \
        pip \
        "awscli==${AWS_CLI_VERSION}" ; \
    \
    python3 --version ; \
    aws --version ; \
    docker --version ; \
    \
    rm -rf ~/.cache

ARG kubectl_version=1.15.4
ENV KUBECTL_VERSION ${kubectl_version}

ENV KUBECTL_DL_URL="https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

RUN set -eux ; \
    wget -q -O /usr/local/bin/kubectl "${KUBECTL_DL_URL}" ; \
    chmod 755 /usr/local/bin/kubectl ; \
    \
    kubectl version --client

COPY kube-config.tmpl /etc/kube-config.tmpl
COPY prepare-ci.sh /usr/local/bin/prepare-ci

CMD ["prepare-ci"]
