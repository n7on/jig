# Introspection commands for grim

# List all registered commands
grim_command_list() {
    _grim_command_param_parse "$@" || return 1

    _grim_command_exec_python grim command_docs.py "$_GRIM_DIR/src" --format list \
        | _grim_command_output_render
}

# Show details of a specific command
grim_command_show() {
    _grim_command_param name --required --positional --help "Command name"
    _grim_command_param_parse "$@" || return 1

    _grim_command_exec_python grim command_docs.py "$_GRIM_DIR/src" --format show --command "$name" \
        | _grim_command_output_render
}

# Generate markdown documentation for all commands
grim_command_docs() {
    _grim_command_param_parse "$@" || return 1

    _grim_command_exec_python grim command_docs.py "$_GRIM_DIR/src" --format docs --grim-bin "grim"
}

_grim_command_complete_params "grim_command_list" "List all registered grim commands"
_grim_command_complete_params "grim_command_show" "Show parameters for a grim command" "name"
_grim_command_complete_params "grim_command_docs" "Generate markdown documentation for all grim commands"

# Complete command names for grim_command_show
_grim_command_show_complete() {
    local names=""
    for _key in "${!_GRIM_COMMAND_DESCRIPTION[@]}"; do
        names+="$_key "
    done
    # Also add commands from params registry (for commands not yet called)
    local -A seen
    for _key in "${!_GRIM_COMMAND_PARAMS[@]}"; do
        local _cmd="${_key%%:*}"
        [[ -v seen[$_cmd] ]] && continue
        [[ "$_cmd" == _* ]] && continue
        seen[$_cmd]=1
        names+="$_cmd "
    done
    _grim_command_complete_filter "$names" "$1"
}
_grim_command_complete_func "grim_command_show" "name" _grim_command_show_complete
