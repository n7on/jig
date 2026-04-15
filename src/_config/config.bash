# Module configuration management

# Get the config file path for a namespace/module
# Usage: _config_file azure ado
_config_file() {
    echo "$HOME/.jig/$1/$2.json"
}

# Lazily initialise a module config file from its example in the repo.
# Copies src/<namespace>/<module>.json.example to ~/.jig/<namespace>/<module>.json on first use.
# Usage: _config_init <namespace> <module> (called at module scope, not inside functions)
_config_init() {
    local namespace="$1"
    local module="$2"
    local config_file
    config_file=$(_config_file "$namespace" "$module")
    local example="$_JIG_DIR/src/$namespace/$module.json.example"

    if [[ ! -f "$config_file" && -f "$example" ]]; then
        mkdir -p "$(dirname "$config_file")"
        cp "$example" "$config_file"
        _message_warn "Created $config_file — edit it to configure $namespace/$module"
    fi
}

# Read a key from a module config file
# Usage: _config_get <namespace> <module> <key>
_config_get() {
    local config_file
    config_file=$(_config_file "$1" "$2")
    [[ -f "$config_file" ]] || return 0
    cat "$config_file" | json_get --path "$3" 2>/dev/null
}

# Write a key/value to a module config file
# Usage: _config_set <namespace> <module> <key> <value>
_config_set() {
    local config_file
    config_file=$(_config_file "$1" "$2")
    if [[ ! -f "$config_file" ]]; then
        _message_error "Config file not found: $config_file"
        return 1
    fi
    json_set --file "$config_file" --key "$3" --value "$4" || return 1
}

# Append an item to a JSON array config file
# Usage: _config_append <namespace> <module> <json-object>
_config_append() {
    local config_file
    config_file=$(_config_file "$1" "$2")
    mkdir -p "$(dirname "$config_file")"
    json_append --file "$config_file" --item "$3"
}

# Remove matching items from a JSON array config file
# Usage: _config_remove <namespace> <module> <field> <value>
_config_remove() {
    local config_file
    config_file=$(_config_file "$1" "$2")
    [[ -f "$config_file" ]] || return 0
    json_remove --file "$config_file" --match "$3" --value "$4"
}

# Read a JSON array config file as TSV
# Usage: _config_list <namespace> <module> <fields>
_config_list() {
    local config_file
    config_file=$(_config_file "$1" "$2")
    [[ -f "$config_file" ]] || return 0
    cat "$config_file" | json_tsv --path '.' --fields "$3"
}
