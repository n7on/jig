# Run NSE script(s) against target
nmap_script_run() {
    _grim_command_requires nmap || return 1
    
    _grim_command_param_init target script ports
    _grim_command_param_parse "$@"

    _grim_command_param_validate target --required || return 1
    _grim_command_param_validate script --required || return 1

    local cmd=(nmap --script="$script" "$target")
    [[ -n "$ports" ]] && cmd+=(-p "$ports")
    
    _grim_command_output_set "PORT,STATE,SERVICE" '/^[0-9]+\//{printf "%s\t%s\t%s\n", $1, $2, $3}'
    _grim_command_run "${cmd[@]}"
}

# Register parameters
_grim_command_complete_params "nmap_script_run" "target" "script" "ports"
