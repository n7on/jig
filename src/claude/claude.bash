# Claude Code integration

# Generate grim tool documentation for Claude Code
# Writes to ~/.claude/rules/grim.md
claude_generate() {
    _grim_command_param_parse "$@" || return 1

    local rules_dir="$HOME/.claude/rules"
    local output="$rules_dir/grim.md"

    mkdir -p "$rules_dir"
    grim_command_docs > "$output"
    _grim_message_warn "Generated $output"
}

_grim_command_complete_params "claude_generate" "Generate grim tool docs for Claude Code"
