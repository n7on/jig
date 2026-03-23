
_azure_arm_get_subscriptions() {
    _grim_command_complete_filter "${AZURE_SUBSCRIPTIONS}" "$1"
}

azure_arm_subscription() {
    _grim_command_description "Switch Azure subscription"
    _grim_command_param subscription --required --positional --regex "[^0-9]" --help "Subscription name"
    _grim_command_param_parse "$@" || return 1

    az account set --subscription "$subscription"
}

# Register completions
_grim_command_complete_params "azure_arm_subscription" "subscription"
_grim_command_complete_func "azure_arm_subscription" "subscription" _azure_arm_get_subscriptions
