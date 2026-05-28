FROM hashicorp/consul:1.22 AS builder-consul
FROM hashicorp/nomad:1.11 AS builder-nomad

FROM ubuntu:24.04

COPY --from=builder-consul /bin/consul /usr/bin/consul
COPY --from=builder-nomad /bin/nomad /usr/bin/nomad

COPY hashibackup.sh /usr/bin/hashibackup
COPY entrypoint.sh /usr/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

CMD ["hashibackup"]
