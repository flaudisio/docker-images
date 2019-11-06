FROM docker:19

RUN set -eux ; \
    apk add --no-cache \
        py3-pip ; \
    rm -rf ~/.cache

COPY requirements.txt /tmp/requirements.txt

RUN set -eux ; \
    pip3 install -r \
        /tmp/requirements.txt ; \
    rm -rf ~/.cache

COPY build.py /usr/local/bin/pydib

CMD ["pydib"]
