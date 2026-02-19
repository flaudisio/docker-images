FROM hashicorp/consul:1.22 AS builder-consul
FROM hashicorp/nomad:1.11 AS builder-nomad

FROM ubuntu:24.04

COPY --from=builder-consul /bin/consul /bin/consul
COPY --from=builder-nomad /bin/nomad /bin/nomad

COPY hashibackup.sh /bin/hashibackup
COPY entrypoint.sh /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["hashibackup"]
