#!/bin/sh

# shellcheck shell=dash

set -e
set -o pipefail

: "${SC_REQUIRED_SPACE:="5368709120"}" # 5 GiB
: "${SC_QBITTORRENT_API_KEY:=""}"
: "${SC_QBITTORRENT_BASE_URL:=""}"

_msg()
{
    echo "$*" >&2
}

main()
{
    local required_space="${1:-"$SC_REQUIRED_SPACE"}"
    local free_space

    if ! free_space="$(
        curl -f -m 5 -sSL -H "Authorization: Bearer $SC_QBITTORRENT_API_KEY" "${SC_QBITTORRENT_BASE_URL}/api/v2/sync/maindata" \
            | jq -r '.server_state.free_space_on_disk'
    )"
    then
        _msg "Error: could not fetch free disk space on qBittorrent server"
        exit 1
    fi

    if [ "$required_space" -ge "$free_space" ] ; then
        _msg "Fail: not enough space on qBittorrent server (required: $required_space bytes, free: $free_space)"
        exit 1
    fi

    _msg "Success: qBittorrent server has enough free space (required: $required_space bytes, free: $free_space)"
    exit 0
}

main "$@"
