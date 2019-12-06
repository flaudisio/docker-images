FROM {{ cookiecutter.base_image }}

LABEL \
    maintainer="{{ cookiecutter.maintainer_name }} <{{ cookiecutter.maintainer_email }}>" \
    com.flaudisio.type="{{ cookiecutter.image_type.split('::') | first | trim }}" \
    com.flaudisio.name="{{ cookiecutter.image_pretty_name }}" \
    com.flaudisio.vcs-ref="https://github.com/flaudisio/docker-images"

ARG sometool_version=1.0
ENV SOMETOOL_VERSION ${sometool_version}

{% if "python" in cookiecutter.base_image -%}
RUN set -eux ; \
    apk add --no-cache \
        dependency1 \
        dependency2 ; \
    pip install \
        "sometool==${SOMETOOL_VERSION}" ; \
    \
    dependency1 --version ; \
    dependency2 --version ; \
    some-tool --version ; \
    \
    rm -rf ~/.cache
{% else -%}
RUN set -eux ; \
    wget -q -O /usr/local/bin/some-tool https://github.com/some-user/some-tool/releases/download/${SOMETOOL_VERSION}/some-tool-linux-amd64 ; \
    chmod -v 755 /usr/local/bin/some-tool
{%- endif %}

CMD ["some-tool", "--version"]
