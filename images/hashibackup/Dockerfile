ARG consul_version=latest
ARG nomad_version=latest

FROM hashicorp/consul:${consul_version} AS consul-base
FROM hashicorp/nomad:${nomad_version} AS nomad-base

FROM ubuntu:24.04

COPY --from=consul-base /bin/consul /usr/bin/consul
COPY --from=nomad-base /bin/nomad /usr/bin/nomad

RUN set -ex \
 && apt-get update -q \
 && apt-get install -q -y --no-install-recommends \
        ca-certificates \
        tzdata \
 && rm -rf /var/lib/apt/lists/*

COPY hashibackup.sh /usr/bin/hashibackup
COPY entrypoint.sh /usr/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

CMD ["hashibackup"]
