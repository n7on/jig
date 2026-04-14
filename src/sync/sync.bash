_require_module "git"

sync() {
    _description "Commit and push changes in ~/.rig to its remote"
    _param message --default "sync" --help "Commit message"
    _param_parse "$@" || return 1

    if [[ ! -d "$HOME/.rig/.git" ]]; then
        _message_error "~/.rig is not a git repository. Initialize it first:
  git -C ~/.rig init
  git -C ~/.rig remote add origin <url>
  git -C ~/.rig add .
  git -C ~/.rig commit -m 'init'
  git -C ~/.rig push -u origin main"
        return 1
    fi

    git_sync --path "$HOME/.rig" --message "$message"
}

_complete_type "sync" action
_complete_params "sync" "message"
