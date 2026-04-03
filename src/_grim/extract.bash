# JSON and text extraction helpers

# Get a single value from JSON by path
# Usage: echo "$json" | _grim_json_get 'appId'
#        echo "$json" | _grim_json_get 'subscriptions.0.user.name'
_grim_json_get() {
    "$_GRIM_PYTHON" "$_GRIM_DIR/src/_grim/python/json_get.py" "$@"
}

# Extract fields from JSON as TSV with headers
# Usage: echo "$json" | _grim_json_tsv 'value' 'name=displayName' 'id'
#        echo "$json" | _grim_json_tsv '.' --kv
_grim_json_tsv() {
    "$_GRIM_PYTHON" "$_GRIM_DIR/src/_grim/python/json_tsv.py" "$@"
}

# Find first matching item in a JSON array
# With return field:  echo "$json" | _grim_json_find 'appRoles' 'value' 'User.Read' 'id'
# Whole object:       echo "$json" | _grim_json_find '.' 'displayName' 'myapp'
_grim_json_find() {
    "$_GRIM_PYTHON" "$_GRIM_DIR/src/_grim/python/json_find.py" "$@"
}

# Build a JSON object from key=value pairs
# Usage: _grim_json_build 'name=foo' 'int:count=42' 'bool:active=true'
#        _grim_json_build --base "$existing" 'extra=bar'
#        _grim_json_build 'retentionDuration.days=30'  (nested)
# Empty values are omitted automatically.
_grim_json_build() {
    "$_GRIM_PYTHON" "$_GRIM_DIR/src/_grim/python/json_build.py" "$@"
}

# Extract fields from text using awk
# Usage: echo "$text" | _grim_text_extract '/^[0-9]+\//' 'port=$1' 'state=$2' 'service=$3'
_grim_text_extract() {
    local pattern="$1"
    shift

    # Build headers from mappings
    local headers=""
    for mapping in "$@"; do
        [[ -n "$headers" ]] && headers+=","
        headers+="${mapping%%=*}"
    done
    echo "$headers"

    # Build awk printf
    local printf_fmt="" printf_vars=""
    for mapping in "$@"; do
        [[ -n "$printf_fmt" ]] && printf_fmt+="\\t"
        printf_fmt+="%s"
        [[ -n "$printf_vars" ]] && printf_vars+=", "
        printf_vars+="${mapping#*=}"
    done
    awk "$pattern{printf \"${printf_fmt}\\n\", ${printf_vars}}"
}
