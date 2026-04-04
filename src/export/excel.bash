export_excel() {
    _grim_command_param output --default "export.xlsx" --help "Output .xlsx file path"
    _grim_command_param sheet  --default "Sheet1"      --help "Sheet name (appends if file exists)"
    _grim_command_param input  --path file             --help "Input TSV file (default: stdin)"
    _grim_command_param_parse "$@" || return 1

    if [[ -n "$input" ]]; then
        _grim_command_exec_python export excel.py --output "$output" --sheet "$sheet" < "$input"
    else
        _grim_command_exec_python export excel.py --output "$output" --sheet "$sheet"
    fi
}

_grim_command_complete_params "export_excel" "Convert TSV input to a formatted Excel (.xlsx) file" output sheet input
