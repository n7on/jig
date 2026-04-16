_require_module "json"

_PACK_DIR="$HOME/.jig/pack"
_PACK_REGISTRY="$(dirname "${BASH_SOURCE[0]}")/packs.json"

# Resolve a pack name or git URL to a clone URL.
# URL-shaped (contains '://' or starts with 'git@') is returned unchanged;
# otherwise looks up the name in the registry.
_pack_resolve_url() {
    local arg="$1"

    if [[ "$arg" == *"://"* || "$arg" == git@* ]]; then
        echo "$arg"
        return 0
    fi

    [[ -f "$_PACK_REGISTRY" ]] || {
        _message_error "Registry not found: $_PACK_REGISTRY"
        return 1
    }

    local url
    url=$(cat "$_PACK_REGISTRY" \
        | json_find --path '.' --where 'name' --equals "$arg" --return 'url')

    if [[ -z "$url" || "$url" == "-" ]]; then
        _message_error "Unknown pack '$arg'. Run 'jig pack available' to see the registry, or pass a git URL."
        return 1
    fi

    echo "$url"
}

_pack_install_dir() {
    local name="$1" url="$2" dest="$3"

    # Clone to a temp location first so we can check for conflicts
    local tmp
    tmp=$(mktemp -d)
    _exec git clone "$url" "$tmp/$name" || { rm -rf "$tmp"; return 1; }

    # Check for namespace conflicts with built-ins and other installed packs
    local conflicts=()
    local ns_dir ns
    for ns_dir in "$tmp/$name/src"/*/; do
        [[ -d "$ns_dir" ]] || continue
        ns="$(basename "$ns_dir")"
        [[ "$ns" == _* ]] && continue
        if [[ -d "$_JIG_DIR/src/$ns" ]]; then
            conflicts+=("$ns (built-in)")
            continue
        fi
        local existing
        for existing in "$_PACK_DIR"/*/src/"$ns"; do
            if [[ -d "$existing" ]]; then
                conflicts+=("$ns ($(basename "$(dirname "$(dirname "$existing")")")")
                break
            fi
        done
    done

    if [[ ${#conflicts[@]} -gt 0 ]]; then
        rm -rf "$tmp"
        _message_error "Namespace conflicts: ${conflicts[*]}"
        return 1
    fi

    mv "$tmp/$name" "$dest"
    rm -rf "$tmp"

    if [[ -f "$dest/requirements.txt" ]]; then
        echo "Installing Python dependencies for $name..."
        "$HOME/.jig/.venv/bin/pip" install --quiet --disable-pip-version-check \
            -r "$dest/requirements.txt"
    fi

    # Copy example config files to ~/.jig/<namespace>/
    local example ns
    for example in "$dest"/src/*/*.json.example; do
        [[ -f "$example" ]] || continue
        ns="$(basename "$(dirname "$example")")"
        local config_name config_dest
        config_name="$(basename "$example" .example)"
        config_dest="$HOME/.jig/$ns/$config_name"
        if [[ ! -f "$config_dest" ]]; then
            mkdir -p "$HOME/.jig/$ns"
            cp "$example" "$config_dest"
            _message_warn "Created $config_dest — edit it to configure $ns"
        fi
    done
}

pack_install() {
    _description "Install a pack by registry name or git URL"
    _requires git || return 1
    _param pack --required --positional --help "Pack name (from registry) or git repository URL"
    _param_parse "$@" || return 1

    local url
    url=$(_pack_resolve_url "$pack") || return 1

    local name
    name="$(basename "$url" .git)"
    local dest="$_PACK_DIR/$name"

    if [[ -d "$dest" ]]; then
        _message_error "Pack '$name' is already installed. Use 'jig pack update $name' to update."
        return 1
    fi

    mkdir -p "$_PACK_DIR"
    _pack_install_dir "$name" "$url" "$dest" || return 1

    _config_append "pack" "packs" "$(json_build "name=$name" "url=$url")"
    _message_warn "Installed: $name"
}

pack_available() {
    _description "List packs available in the jig registry"
    _param_parse "$@" || return 1

    _exec_python pack available.py "$_PACK_REGISTRY" "$_PACK_DIR" \
        | _output_render
}

pack_list() {
    _description "List installed packs and their namespaces"
    _param_parse "$@" || return 1

    {
        # Built-in namespaces
        local ns_dir ns
        for ns_dir in "$_JIG_DIR/src"/*/; do
            ns="$(basename "$ns_dir")"
            [[ "$ns" == _* ]] && continue
            printf "%s\t%s\n" "$ns" "built-in"
        done

        # Installed packs
        local pack_dir pack_name
        for pack_dir in "$_PACK_DIR"/*/; do
            [[ -d "$pack_dir/src" ]] || continue
            pack_name="$(basename "$pack_dir")"
            for ns_dir in "$pack_dir/src"/*/; do
                ns="$(basename "$ns_dir")"
                [[ "$ns" == _* ]] && continue
                printf "%s\t%s\n" "$ns" "$pack_name"
            done
        done
    } | _output_render "namespace,pack"
}

pack_remove() {
    _description "Remove an installed pack"
    _param name --required --positional --help "Pack name"
    _param_parse "$@" || return 1

    local dest="$_PACK_DIR/$name"
    if [[ ! -d "$dest" ]]; then
        _message_error "Pack '$name' not found in $_PACK_DIR"
        return 1
    fi

    rm -rf "$dest"
    _config_remove "pack" "packs" "name" "$name"
    _message_warn "Removed: $name"
}

pack_update() {
    _description "Update an installed pack"
    _requires git || return 1
    _param name --positional --help "Pack name to update (omit for all)"
    _param_parse "$@" || return 1

    local targets=()
    if [[ -n "$name" ]]; then
        [[ -d "$_PACK_DIR/$name" ]] || { _message_error "Pack '$name' not found"; return 1; }
        targets=("$_PACK_DIR/$name")
    else
        local d
        for d in "$_PACK_DIR"/*/; do
            [[ -d "$d" ]] && targets+=("$d")
        done
    fi

    local dir n
    for dir in "${targets[@]}"; do
        n="$(basename "$dir")"
        if [[ ! -d "$dir/.git" ]]; then
            _message_error "'$n' is not a git repository"
            continue
        fi
        if _exec git -C "$dir" pull --quiet; then
            if [[ -f "$dir/requirements.txt" ]]; then
                "$HOME/.jig/.venv/bin/pip" install --quiet --disable-pip-version-check \
                    -r "$dir/requirements.txt"
            fi
            _message_warn "Updated: $n"
        fi
    done
}

_pack_complete_name() {
    local d
    for d in "$_PACK_DIR"/*/; do
        [[ -d "$d" ]] && basename "$d"
    done
}

# Complete with registry names that are not yet installed
_pack_complete_available() {
    [[ -f "$_PACK_REGISTRY" ]] || return 0
    local name
    while IFS=$'\t' read -r name _; do
        [[ -d "$_PACK_DIR/$name" ]] || echo "$name"
    done < <(cat "$_PACK_REGISTRY" \
        | json_tsv --path '.' --fields 'name' 2>/dev/null \
        | tail -n +2)
}

_complete_params "pack_available"
_complete_type "pack_install" action
_complete_params "pack_install" "pack"
_complete_func "pack_install" "pack" _pack_complete_available
_complete_params "pack_list"
_complete_type "pack_remove" action
_complete_params "pack_remove" "name"
_complete_func "pack_remove" "name" _pack_complete_name
_complete_type "pack_update" action
_complete_params "pack_update" "name"
_complete_func "pack_update" "name" _pack_complete_name
