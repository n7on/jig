# Introspection commands for jig

# Collect all src dirs: core + installed packs
_command_src_dirs() {
    echo "$_JIG_DIR/src"
    local repo
    for repo in "$HOME/.jig/pack"/*/; do
        [[ -d "$repo/src" ]] && echo "$repo/src"
    done
}

# List all registered commands
command_list() {
    _description "List all registered jig commands"
    _param_parse "$@" || return 1

    _exec_python command command_docs.py $(_command_src_dirs) --format list \
        | _output_render
}

# Show details of a specific command
command_show() {
    _description "Show parameters for a jig command"
    _param name --required --positional --help "Command name"
    _param_parse "$@" || return 1

    _exec_python command command_docs.py $(_command_src_dirs) --format show --command "$name" \
        | _output_render
}

# Generate markdown documentation for all commands
command_docs() {
    _description "Generate markdown documentation for all jig commands"
    _param_parse "$@" || return 1

    _exec_python command command_docs.py $(_command_src_dirs) --format docs --bin "jig"
}

_complete_params "command_list"
_complete_params "command_show" "name"
_complete_params "command_docs"

_command_show_complete() {
    # Load all namespaces to get the full command list
    local ns_dir ns
    for ns_dir in "$_JIG_DIR/src"/*/; do
        ns="$(basename "$ns_dir")"
        [[ "$ns" == _* ]] && continue
        _require_module "$ns" 2>/dev/null
    done
    for _vol in "$HOME/.jig/pack"/*/; do
        [[ -d "$_vol/src" ]] || continue
        for ns_dir in "$_vol/src"/*/; do
            ns="$(basename "$ns_dir")"
            [[ "$ns" == _* ]] && continue
            _require_module "$ns" 2>/dev/null
        done
    done

    local names="" _cmd
    local -A seen
    for _key in "${!_PARAMS[@]}"; do
        _cmd="${_key%%:*}"
        [[ -v seen[$_cmd] ]] && continue
        [[ "$_cmd" == _* ]] && continue
        seen[$_cmd]=1
        names+="$_cmd "
    done
    _complete_filter "$names" "$1"
}
_complete_func "command_show" "name" _command_show_complete
