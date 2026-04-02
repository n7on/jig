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

    case "$format" in
        raw|json|tsv|table) ;;
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

    # Apply --filter if set
    if [[ -n "${filter:-}" ]]; then
        data=$(_grim_command_output_filter "$headers" "$data" "$filter")
        if [[ -z "$data" ]]; then
            _grim_message_warn "No results match filter: $filter"
            return 0
        fi
    fi

    # Apply --sort if set
    if [[ -n "${sort:-}" ]]; then
        data=$(_grim_command_output_sort "$headers" "$data" "$sort")
    fi

    # Apply --select if set (must be last — rewrites headers and data)
    if [[ -n "${select:-}" ]]; then
        local selected
        selected=$(_grim_command_output_select "$headers" "$data" "$select")
        headers="${selected%%$'\n'*}"
        data="${selected#*$'\n'}"
    fi

    # Apply --limit if set
    if [[ -n "${limit:-}" ]]; then
        data=$(echo "$data" | head -n "$limit")
    fi

    case "$format" in
        raw)
            echo "$input"
            ;;
        json)
            _grim_command_output_json "$headers" "$data"
            ;;
        tsv)
            _grim_command_output_tsv "$headers" "$data"
            ;;
        table)
            _grim_command_output_table "$headers" "$data"
            ;;
    esac
}

# Filter rows by column value
# Supports exact match (STATE=running) and wildcard (NAME=web*)
# Usage: _grim_command_output_filter "COL1,COL2" "$data" "COL1=value"
_grim_command_output_filter() {
    local headers="$1"
    local data="$2"
    local filter_expr="$3"

    local filter_col="${filter_expr%%=*}"
    local filter_val="${filter_expr#*=}"

    # Find column index (case insensitive)
    IFS=',' read -ra header_arr <<< "$headers"
    local col_idx=-1
    local filter_col_upper="${filter_col^^}"
    for i in "${!header_arr[@]}"; do
        if [[ "${header_arr[$i]^^}" == "$filter_col_upper" ]]; then
            col_idx=$i
            break
        fi
    done

    if [[ $col_idx -lt 0 ]]; then
        _grim_message_error "Unknown filter column: $filter_col (available: $headers)"
        return 1
    fi

    local result=""
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        IFS=$'\t' read -ra fields <<< "$line"
        local field_val="${fields[$col_idx]:-}"

        # Wildcard match using bash pattern matching
        if [[ "$field_val" == $filter_val ]]; then
            if [[ -n "$result" ]]; then
                result+=$'\n'
            fi
            result+="$line"
        fi
    done <<< "$data"

    echo "$result"
}

# Sort rows by column value
# Prefix column name with - for descending order
# Usage: _grim_command_output_sort "COL1,COL2" "$data" "COL1"
#        _grim_command_output_sort "COL1,COL2" "$data" "-COL1"
_grim_command_output_sort() {
    local headers="$1"
    local data="$2"
    local sort_expr="$3"

    local descending=false
    local sort_col="$sort_expr"
    if [[ "$sort_col" == -* ]]; then
        descending=true
        sort_col="${sort_col#-}"
    fi

    # Find column index (1-based for sort -k, case insensitive)
    IFS=',' read -ra header_arr <<< "$headers"
    local col_idx=-1
    local sort_col_upper="${sort_col^^}"
    for i in "${!header_arr[@]}"; do
        if [[ "${header_arr[$i]^^}" == "$sort_col_upper" ]]; then
            col_idx=$((i + 1))
            break
        fi
    done

    if [[ $col_idx -lt 0 ]]; then
        _grim_message_error "Unknown sort column: $sort_col (available: $headers)"
        echo "$data"
        return 1
    fi

    local sort_flags=(-t $'\t' -k "${col_idx},${col_idx}")
    $descending && sort_flags+=(-r)

    echo "$data" | sort "${sort_flags[@]}"
}

# Select specific columns from the output
# Returns new headers on first line, then data rows
# Usage: _grim_command_output_select "COL1,COL2,COL3" "$data" "COL1,COL3"
_grim_command_output_select() {
    local headers="$1"
    local data="$2"
    local select_expr="$3"

    IFS=',' read -ra header_arr <<< "$headers"
    IFS=',' read -ra select_arr <<< "$select_expr"

    # Resolve column indices (case insensitive)
    local -a col_indices=()
    for sel in "${select_arr[@]}"; do
        local found=false
        local sel_upper="${sel^^}"
        for i in "${!header_arr[@]}"; do
            if [[ "${header_arr[$i]^^}" == "$sel_upper" ]]; then
                col_indices+=("$i")
                found=true
                break
            fi
        done
        if ! $found; then
            _grim_message_error "Unknown select column: $sel (available: $headers)"
            return 1
        fi
    done

    # Output new headers (using original casing)
    local new_headers=""
    for i in "${col_indices[@]}"; do
        [[ -n "$new_headers" ]] && new_headers+=","
        new_headers+="${header_arr[$i]}"
    done
    echo "$new_headers"

    # Output selected columns for each row
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        IFS=$'\t' read -ra fields <<< "$line"
        local row=""
        for i in "${col_indices[@]}"; do
            [[ -n "$row" ]] && row+=$'\t'
            row+="${fields[$i]:-}"
        done
        echo "$row"
    done <<< "$data"
}

# Output as JSON array
_grim_command_output_json() {
    local headers="$1"
    local data="$2"
    
    _grim_command_requires jq || {
        _grim_message_error "jq required for JSON output"
        return 1
    }
    
    # Split headers into array
    IFS=',' read -ra header_arr <<< "$headers"
    
    # Build JSON
    local json="["
    local first_row=true
    
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        
        # Split line into fields — replace tab with \x1f (non-whitespace IFS char)
        # so that consecutive empty fields and leading empty fields are preserved.
        # Tab is a whitespace IFS char in bash, causing consecutive tabs to collapse.
        IFS=$'\x1f' read -ra fields <<< "${line//$'\t'/$'\x1f'}"
        
        $first_row || json+=","
        first_row=false
        
        json+="{"
        local first_field=true
        for i in "${!header_arr[@]}"; do
            $first_field || json+=","
            first_field=false
            local key="${header_arr[$i]}"
            local value="${fields[$i]:-}"
            # Escape quotes in value
            value="${value//\"/\\\"}"
            json+="\"$key\":\"$value\""
        done
        json+="}"
    done <<< "$data"
    
    json+="]"
    
    echo "$json" | jq .
}

# Output as TSV
_grim_command_output_tsv() {
    local headers="$1"
    local data="$2"

    echo "${headers//,/$'\t'}"
    echo "$data"
}

# Output as formatted table
_grim_command_output_table() {
    local headers="$1"
    local data="$2"
    
    # Combine headers and data for column formatting
    {
        echo "${headers//,/$'\t'}"
        echo "$data"
    } | column -t -s $'\t'
}
