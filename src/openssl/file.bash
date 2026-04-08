# Encrypt a file using AES-256-CBC
openssl_file_encrypt() {
    _description "Encrypt a file using AES-256-CBC"
    _requires openssl || return 1
    _param input --required --path file --help "Input file to encrypt"
    _param output --help "Output file (default: input.enc)"
    _param password --required --help "Encryption password"
    _param cipher --default aes-256-cbc --help "Cipher algorithm"
    _param_parse "$@" || return 1

    [[ -z "$output" ]] && output="${input}.enc"

    local cmd=(openssl enc -"${cipher}" -salt -pbkdf2 -in "$input" -out "$output" -pass "pass:${password}")

    _exec "${cmd[@]}"
}

# Decrypt a file
openssl_file_decrypt() {
    _description "Decrypt a file"
    _requires openssl || return 1
    _param input --required --path file --help "Input file to decrypt"
    _param output --help "Output file (default: input without .enc)"
    _param password --required --help "Decryption password"
    _param cipher --default aes-256-cbc --help "Cipher algorithm"
    _param_parse "$@" || return 1

    [[ -z "$output" ]] && output="${input%.enc}"

    local cmd=(openssl enc -d -"${cipher}" -pbkdf2 -in "$input" -out "$output" -pass "pass:${password}")

    _exec "${cmd[@]}" || _message_error "Decryption failed: wrong password or corrupted file"
}

# Register completions
_complete_type "openssl_file_encrypt" action
_complete_params "openssl_file_encrypt" "input" "output" "password" "cipher"
_complete_type "openssl_file_decrypt" action
_complete_params "openssl_file_decrypt" "input" "output" "password" "cipher"
_complete_values "openssl_file_encrypt" "cipher" "aes-256-cbc" "aes-128-cbc"
_complete_values "openssl_file_decrypt" "cipher" "aes-256-cbc" "aes-128-cbc"
