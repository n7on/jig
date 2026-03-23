
_azure_ado_app_id="499b84ac-1321-427f-aa17-267ca6975798"

azure_ado_download_latest_feed_package() {
    _grim_command_requires jq az || return 1
    _grim_command_description "Download latest package from Azure DevOps feed"
    _grim_command_param package --required --positional --help "Package name"
    _grim_command_param path --default "." --help "Download path"
    _grim_command_param feed --default "$AZURE_DEVOPS_FEED_NAME" --help "Feed name"
    _grim_command_param organization --default "$AZURE_DEVOPS_ORGANIZATION" --help "Azure DevOps organization"
    _grim_command_param_parse "$@" || return 1

    local url="https://feeds.dev.azure.com/$organization/_apis/packaging/feeds/$feed/packages?packageNameQuery=$package&protocolType=upack&api-version=7.1-preview.1"
    local pkg
    local version

    pkg=$(az rest --method GET --resource "$_ms_ado_app_id" --url "$url" 2>/dev/null | \
        jq -r --arg name "$package" '.value[] | select(.name == $name)')

    [[ -z "$pkg" ]] && _grim_message_error "Package '$package' not found in feed '$feed'" && return 1

    version=$(jq -r '.versions[0].version' <<< "$pkg")

    az artifacts universal download \
        --organization "https://dev.azure.com/$organization/" \
        --feed "$feed" \
        --name "$package" \
        --version "$version" \
        --path "$path/$package"
}

# Register completions
_grim_command_complete_params "azure_ado_download_latest_feed_package" "package" "path" "feed" "organization"
