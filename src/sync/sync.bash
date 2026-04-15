_require_module "git"

sync() {
    _description "Commit and push changes in ~/.jig to its remote"
    _param message --default "sync" --help "Commit message"
    _param_parse "$@" || return 1

    if [[ ! -d "$HOME/.jig/.git" ]]; then
        _message_error "~/.jig is not a git repository. Initialize it first:
  git -C ~/.jig init
  git -C ~/.jig remote add origin <url>
  git -C ~/.jig add .
  git -C ~/.jig commit -m 'init'
  git -C ~/.jig push -u origin main"
        return 1
    fi

    git_sync --path "$HOME/.jig" --message "$message"
}

_complete_type "sync" action
_complete_params "sync" "message"
