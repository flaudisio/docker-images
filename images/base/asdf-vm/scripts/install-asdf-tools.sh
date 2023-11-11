#!/usr/bin/env bash

readonly ToolsFile="${ASDF_DEFAULT_TOOL_VERSIONS_FILENAME:=".tool-versions"}"


msg()
{
    echo -e "--> $*" >&2
}

add_plugins()
{
    msg "Adding plugins"

    grep -v '^#' "$ToolsFile" | cut -d ' ' -f 1 | xargs -I '{}' asdf plugin-add '{}'
}

install_tools()
{
    # Ignore commented or empty lines
    grep -E -v '^(#.*)*$' "$ToolsFile" \
        | \
        while read -r tool version ; do
            [[ -z "$tool" ]] && continue

            msg "Installing $tool $version"

            asdf install "$tool" "$version"
        done
}

main()
{
    if [[ ! -f "$ToolsFile" ]] ; then
        msg "Tools file '$ToolsFile' not found; ignoring"
        exit 0
    fi

    add_plugins
    install_tools
}

main "$@"
