_require_module "pack"
_require_module "json"

_JIG_VENV="$HOME/.jig/.venv"

setup() {
    _description "Set up jig: create venv, install dependencies and packs"
    _param_parse "$@" || return 1

    if ! command -v python3 &>/dev/null; then
        _message_error "python3 is not installed"
        return 1
    fi

    if ! python3 -c "import ensurepip" &>/dev/null; then
        _message_error "python3-venv is not installed. Run: sudo apt install python3-venv"
        return 1
    fi

    if [[ ! -d "$HOME/.jig" ]]; then
        local repo_url=""
        read -rp "Do you have an existing ~/.jig repo to restore from? [y/N] " yn
        if [[ "$yn" =~ ^[Yy] ]]; then
            read -rp "~/.jig repo URL: " repo_url
            if [[ -z "$repo_url" ]]; then
                _message_error "No URL provided"
                return 1
            fi
            _requires git || return 1
            echo "Cloning $repo_url to $HOME/.jig..."
            git clone --quiet "$repo_url" "$HOME/.jig" || return 1
        fi
    fi

    mkdir -p "$HOME/.jig"

    # Create .gitignore if missing
    local gitignore="$HOME/.jig/.gitignore"
    if [[ ! -f "$gitignore" ]]; then
        cat > "$gitignore" <<'EOF'
pack/*/
.venv/
.cache/
EOF
    fi

    echo "Creating venv at $_JIG_VENV..."
    python3 -m venv "$_JIG_VENV"

    if [[ -f "$_JIG_DIR/requirements.txt" ]]; then
        echo "Installing core dependencies..."
        "$_JIG_VENV/bin/pip" install --quiet --disable-pip-version-check \
            -r "$_JIG_DIR/requirements.txt"
    fi

    # Reinstall packs from manifest
    local name url dest
    while IFS=$'\t' read -r name url; do
        dest="$_PACK_DIR/$name"
        if [[ -d "$dest" ]]; then
            _message_warn "Already installed: $name"
            continue
        fi
        echo "Installing pack: $name..."
        _requires git || return 1
        mkdir -p "$_PACK_DIR"
        _pack_install_dir "$name" "$url" "$dest" || continue
        echo "Installed: $name"
    done < <(_config_list "pack" "packs" "name,url")

    local shell_rc=""
    case "${SHELL##*/}" in
        zsh)  shell_rc="$HOME/.zshrc" ;;
        bash) shell_rc="$HOME/.bashrc" ;;
    esac

    if [[ -n "$shell_rc" ]]; then
        local export_line="export PATH=\"\$HOME/source/jig/bin:\$PATH\""
        local source_line="source <(jig completion ${SHELL##*/})"
        local added=0
        if ! grep -qF 'jig/bin' "$shell_rc" 2>/dev/null; then
            echo "$export_line" >> "$shell_rc"
            (( added++ ))
        fi
        if ! grep -qF 'jig completion' "$shell_rc" 2>/dev/null; then
            echo "$source_line" >> "$shell_rc"
            (( added++ ))
        fi
        if (( added > 0 )); then
            echo "Updated $shell_rc — run: source $shell_rc"
        fi
    else
        echo "Add to your shell rc file:"
        echo "  export PATH=\"\$HOME/source/jig/bin:\$PATH\""
        echo "  source <(jig completion bash)   # or zsh"
    fi

    echo "Setup complete."
}

_complete_type "setup" action
_complete_params "setup"
