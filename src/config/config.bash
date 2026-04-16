_require_module "json"

# User-facing config commands

_config_get_namespaces() {
    local f
    for f in "$HOME/.jig"/*/config.json; do
        [[ -f "$f" ]] || continue
        basename "$(dirname "$f")"
    done
}

_config_complete_namespace() {
    _complete_filter "$(_config_get_namespaces)" "$1"
}

_config_complete_key() {
    local ns=""
    local i
    for ((i=0; i<${#_COMP_WORDS[@]}; i++)); do
        if [[ "${_COMP_WORDS[$i]}" == "--namespace" && -n "${_COMP_WORDS[$((i+1))]:-}" ]]; then
            ns="${_COMP_WORDS[$((i+1))]}"
            break
        fi
    done
    [[ -z "$ns" ]] && return 0

    local config_file="$HOME/.jig/$ns/config.json"
    [[ -f "$config_file" ]] || return 0

    local keys
    keys=$(cat "$config_file" | json_kv 2>/dev/null | tail -n +2 | awk '{print $1}')
    _complete_filter "$keys" "$1"
}

config_show() {
    _description "Show all config values for a module"
    _param namespace --required --positional --help "Config namespace (e.g. ado)"
    _param module    --default "config" --help "Config module name"
    _param_parse "$@" || return 1

    local config_file
    config_file=$(_config_file "$namespace" "$module")

    if [[ ! -f "$config_file" ]]; then
        _message_error "Config not found: $config_file"
        return 1
    fi

    cat "$config_file" | json_kv | _output_render
}

config_get() {
    _description "Get a config value"
    _param namespace --required --positional --help "Config namespace (e.g. ado)"
    _param key       --required --help "Config key"
    _param module    --default "config" --help "Config module name"
    _param_parse "$@" || return 1

    local config_file
    config_file=$(_config_file "$namespace" "$module")

    if [[ ! -f "$config_file" ]]; then
        _message_error "Config not found: $config_file"
        return 1
    fi

    local value
    value=$(cat "$config_file" | json_get --path "$key" 2>/dev/null) || {
        _message_error "Key '$key' not found in $namespace/$module"
        return 1
    }

    echo "$value"
}

config_set() {
    _description "Set a config value"
    _param namespace --required --positional --help "Config namespace (e.g. ado)"
    _param key       --required --help "Config key"
    _param value     --required --help "Value to set"
    _param module    --default "config" --help "Config module name"
    _param_parse "$@" || return 1

    _config_set "$namespace" "$module" "$key" "$value" || return 1
    _message_warn "Set $namespace/$module: $key = $value"
}

_complete_type "config_show" action
_complete_params "config_show" "namespace" "module"
_complete_func "config_show" "namespace" _config_complete_namespace

_complete_type "config_get" action
_complete_params "config_get" "namespace" "key" "module"
_complete_func "config_get" "namespace" _config_complete_namespace
_complete_func "config_get" "key" _config_complete_key

_complete_type "config_set" action
_complete_params "config_set" "namespace" "key" "value" "module"
_complete_func "config_set" "namespace" _config_complete_namespace
_complete_func "config_set" "key" _config_complete_key
