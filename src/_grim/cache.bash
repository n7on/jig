# Cache management for grim commands
_GRIM_CACHE_DIR="${HOME}/.grim/cache"

# Generate a cache key from arguments
# Usage: _grim_cache_key "func_name" "arg1" "arg2"
_grim_cache_key() {
    echo -n "$*" | md5
}

# Wrap a command with caching support
# Reads $cache from caller scope (set by --cache parameter)
# Usage: _grim_cache_wrap command arg1 arg2
_grim_cache_wrap() {
    local cache_ttl="${cache:-0}"

    if [[ "$cache_ttl" -le 0 ]]; then
        "$@"
        return
    fi

    local key
    key=$(_grim_cache_key "${FUNCNAME[2]}" "$@")
    local cache_file="${_GRIM_CACHE_DIR}/${key}"

    mkdir -p "$_GRIM_CACHE_DIR"

    if [[ -f "$cache_file" ]]; then
        local age=$(( $(date +%s) - $(stat -f%m "$cache_file") ))
        if (( age < cache_ttl )); then
            cat "$cache_file"
            return 0
        fi
    fi

    local output
    output=$("$@") || { echo "$output"; return 1; }

    if [[ -n "$output" ]]; then
        echo "$output" > "$cache_file"
    fi
    echo "$output"
}

# Clear all cached data
# Usage: grim_cache_clear
grim_cache_clear() {
    if [[ -d "$_GRIM_CACHE_DIR" ]]; then
        rm -rf "$_GRIM_CACHE_DIR"
        _grim_message_warn "Cache cleared"
    fi
}
