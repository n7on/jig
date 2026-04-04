# Git sync utilities for directories managed by git

# Pull from remote if directory is a git repo
# Usage: git_pull --path ~/my-repo
git_pull() {
    _grim_command_requires git || return 1
    _grim_command_param path --default "." --positional --path dir --help "Path to git repository"
    _grim_command_param_parse "$@" || return 1

    [[ -d "$path/.git" ]] || return 0
    git -C "$path" pull --quiet 2>/dev/null || _grim_message_warn "git pull failed in $path"
}

# Stage, commit, and push changes if directory is a git repo
# Usage: git_push --path ~/my-repo --message "updated files"
git_push() {
    _grim_command_requires git || return 1
    _grim_command_param path    --default "." --positional --path dir --help "Path to git repository"
    _grim_command_param message --required --help "Commit message"
    _grim_command_param_parse "$@" || return 1

    [[ -d "$path/.git" ]] || return 0
    git -C "$path" add -A
    git -C "$path" diff --cached --quiet && return 0
    git -C "$path" commit --quiet -m "$message" 2>/dev/null || return 1
    git -C "$path" push --quiet 2>/dev/null || _grim_message_warn "git push failed in $path"
}

# Pull, then stage+commit+push (convenience wrapper)
# Usage: git_sync --path ~/my-repo --message "updated files"
git_sync() {
    _grim_command_requires git || return 1
    _grim_command_param path    --default "." --positional --path dir --help "Path to git repository"
    _grim_command_param message --required --help "Commit message"
    _grim_command_param_parse "$@" || return 1

    git_pull --path "$path"
    git_push --path "$path" --message "$message"
}

# Show status of files in a git repo
# Usage: git_status
#        git_status --path ~/my-repo
git_status() {
    _grim_command_requires git || return 1
    _grim_command_param path --default "." --positional --path dir --help "Path to git repository"
    _grim_command_param_parse "$@" || return 1

    git -C "$path" status --porcelain=v1 2>/dev/null \
        | awk '{
            code = substr($0, 1, 2)
            file = substr($0, 4)
            idx = substr(code, 1, 1)
            wt  = substr(code, 2, 1)

            if (code == "??")      state = "untracked"
            else if (idx != " " && wt != " ") state = "staged+modified"
            else if (idx != " ")   state = "staged"
            else                   state = "modified"

            printf "%s\t%s\n", file, state
        }' \
        | _grim_command_output_render "file,status"
}

# Register completions
_grim_command_complete_params "git_status" "Show status of files in a git repo" "path"
_grim_command_complete_params "git_pull" "Pull from remote if directory is a git repo" "path"
_grim_command_complete_params "git_push" "Stage, commit, and push changes" "path" "message"
_grim_command_complete_params "git_sync" "Pull then commit and push changes" "path" "message"
