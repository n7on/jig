# Encrypt a file using AES-256-CBC
openssl_file_encrypt() {
    _grim_command_requires openssl || return 1
    _grim_command_param input --required --path file --help "Input file to encrypt"
    _grim_command_param output --help "Output file (default: input.enc)"
    _grim_command_param password --required --help "Encryption password"
    _grim_command_param cipher --default aes-256-cbc --help "Cipher algorithm"
    _grim_command_param_parse "$@" || return 1

    [[ -z "$output" ]] && output="${input}.enc"

    local cmd=(openssl enc -"${cipher}" -salt -pbkdf2 -in "$input" -out "$output" -pass "pass:${password}")

    _grim_command_exec "${cmd[@]}"
}

# Decrypt a file
openssl_file_decrypt() {
    _grim_command_requires openssl || return 1
    _grim_command_param input --required --path file --help "Input file to decrypt"
    _grim_command_param output --help "Output file (default: input without .enc)"
    _grim_command_param password --required --help "Decryption password"
    _grim_command_param cipher --default aes-256-cbc --help "Cipher algorithm"
    _grim_command_param_parse "$@" || return 1

    [[ -z "$output" ]] && output="${input%.enc}"

    local cmd=(openssl enc -d -"${cipher}" -pbkdf2 -in "$input" -out "$output" -pass "pass:${password}")

    _grim_command_exec "${cmd[@]}" || _grim_message_error "Decryption failed: wrong password or corrupted file"
}

# Register completions
_grim_command_complete_params "openssl_file_encrypt" "Encrypt a file using AES-256-CBC" "input" "output" "password" "cipher"
_grim_command_complete_params "openssl_file_decrypt" "Decrypt a file" "input" "output" "password" "cipher"
_grim_command_complete_values "openssl_file_encrypt" "cipher" "aes-256-cbc" "aes-128-cbc"
_grim_command_complete_values "openssl_file_decrypt" "cipher" "aes-256-cbc" "aes-128-cbc"
