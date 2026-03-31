_GRIM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
_GRIM_PYTHON="$_GRIM_DIR/.venv/bin/python3"

# Source user config
[[ -f "$HOME/.grim/config.env" ]] && source "$HOME/.grim/config.env"

# Source grim utilities first (dependencies)
for _grim_file in "$_GRIM_DIR/src/grim"/*.bash; do
    source "$_grim_file"
done

# Source command modules
for _grim_dir in "$_GRIM_DIR/src"/*; do
    [[ -d "$_grim_dir" && "$(basename "$_grim_dir")" != "grim" ]] || continue
    for _grim_file in "$_grim_dir"/*.bash; do
        [[ -f "$_grim_file" ]] && source "$_grim_file"
    done
done

# Source user extensions from ~/.grim/
for _grim_file in "$HOME/.grim"/*.bash; do
    [[ -f "$_grim_file" ]] && source "$_grim_file"
done

unset _grim_dir _grim_file
