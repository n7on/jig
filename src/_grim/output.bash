# Output formatting for command results
# Supports: table, json, tsv, raw

declare -g _GRIM_OUTPUT_HEADERS=""
declare -g _GRIM_OUTPUT_EXTRACTOR=""
declare -g _GRIM_OUTPUT_TYPE="awk"

# Set output headers and extractor for rendering
# Usage: _grim_command_output_set "IP,PORT,STATE,SERVICE" '{print $2, $1, $3, $4}'
#        _grim_command_output_set "name,ip" '.[].name + "\t" + .[].ip' jq
_grim_command_output_set() {
    _GRIM_OUTPUT_HEADERS="${1,,}"
    _GRIM_OUTPUT_EXTRACTOR="$2"
    _GRIM_OUTPUT_TYPE="${3:-awk}"

    case "$_GRIM_OUTPUT_TYPE" in
        awk|jq) ;;
        *) _grim_message_error "Invalid output type: $_GRIM_OUTPUT_TYPE (expected: awk, jq)"; return 1 ;;
    esac
}

# Format and output data based on selected format
# Usage: echo "$raw_output" | _grim_command_output_render
#        Or: _grim_command_output_render <<< "$raw_output"
_grim_command_output_render() {
    local format="${output_format:-table}"
    local headers="$_GRIM_OUTPUT_HEADERS"
    local extractor="$_GRIM_OUTPUT_EXTRACTOR"
    local type="$_GRIM_OUTPUT_TYPE"

    # Raw format bypasses all processing
    if [[ "$format" == "raw" ]]; then
        cat
        return
    fi

    case "$format" in
        json|tsv|table) ;;
        *) _grim_message_error "Invalid output format: $format (expected: raw, json, tsv, table)"; return 1 ;;
    esac

    # Read input
    local input
    input=$(cat)

    # Extract data using the configured extractor
    local data
    case "$type" in
        jq)
            _grim_command_requires jq || {
                _grim_message_error "jq required for jq extractor"
                return 1
            }
            data=$(echo "$input" | jq -r "$extractor" 2>/dev/null)
            ;;
        awk)
            data=$(echo "$input" | awk "$extractor" 2>/dev/null)
            ;;
    esac

    if [[ -z "$data" ]]; then
        _grim_message_warn "No results found"
        return 0
    fi

    # Build render.py arguments
    local -a args=(--headers "$headers" --format "$format")
    local term_width=${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}
    args+=(--width "$term_width")

    [[ -n "${filter:-}" ]] && args+=(--filter "$filter")
    [[ -n "${sort:-}" ]]   && args+=(--sort "$sort")
    [[ -n "${select:-}" ]] && args+=(--select "$select")
    [[ -n "${limit:-}" ]]  && args+=(--limit "$limit")

    local _python="${_GRIM_PYTHON:-python3}"
    echo "$data" | "$_python" "$_GRIM_DIR/src/_grim/python/render.py" "${args[@]}"
}
