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
        _message_warn "Installed: $name"
    done < <(_config_list "pack" "packs" "name,url")

    echo ""
    echo "Setup complete. Add to your .bashrc or .zshrc:"
    echo ""
    echo "  export PATH=\"\$HOME/source/jig/bin:\$PATH\""
    echo "  source <(jig completion bash)   # or zsh"
}

_complete_type "setup" action
_complete_params "setup"
