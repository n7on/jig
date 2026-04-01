entra_app_list() {
    _grim_command_requires az jq || return 1
    _grim_command_description "List Entra app registrations with their permissions"
    _grim_command_param_parse "$@" || return 1

    local apps
    apps=$(az ad app list --all --output json 2>/dev/null) || {
        _grim_message_error "Failed to list app registrations"
        return 1
    }

    # Build permission GUID -> name map from Microsoft Graph (delegated + app roles)
    local graph_sp
    graph_sp=$(az ad sp show --id "00000003-0000-0000-c000-000000000000" \
        --query "{scopes:oauth2PermissionScopes[].{id:id,value:value},roles:appRoles[].{id:id,value:value}}" \
        --output json 2>/dev/null) || {
        _grim_message_error "Failed to fetch Microsoft Graph permissions"
        return 1
    }
    local perm_map
    perm_map=$(jq '(.scopes + .roles) | map({(.id): .value}) | add // {}' <<< "$graph_sp")

    _grim_command_output_set "NAME,CLIENT_ID,PERMISSIONS" '{print}' awk

    jq -r \
        --argjson permMap "$perm_map" '
        .[] | [
            .displayName,
            .appId,
            ([ .requiredResourceAccess[].resourceAccess[] |
                $permMap[.id] // .id
            ] | join(","))
        ] | @tsv
    ' <<< "$apps" | _grim_command_output_render
}

_grim_command_complete_params entra_app_list
