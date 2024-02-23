#!/usr/bin/env bash
## SOPS adapter functions using 'age' for encryption and decryption.

# Use 'sops' to encrypt a file using an 'age' key.
#
# This is an adapter function for 'sops' that allows providing the 'age' public
# key as an arguments.
#
# Globals:
#   none
# Arguments:
#   $1 - The 'age' public key
#   $2 - The path to the file to encrypt
# Returns:
#   0 - If the file was successfully encrypted
#   1 - If the file could not be encrypted
# Outputs:
#   STDOUT - The encrypted file
#   STDERR - details, on failure
sops::encrypt_with_age() {
    local public_key="$1"
    local file="$2"

    sops --age "$public_key" --encrypt "$file"
}

# Use 'sops' to encrypt a file using an 'age' key in place, i.e., overwrite the file
# with the encrypted content.
#
# This is an adapter function for 'sops' that allows providing the 'age' public
# key as an argument.
#
# Globals:
#   none
# Arguments:
#   $1 - The 'age' public key
#   $2 - The path to the file to encrypt
# Returns:
#   0 - If the file was successfully encrypted
#   1 - If the file could not be encrypted
# Outputs:
#   STDERR - details, on failure
sops::encrypt_in_place_with_age() {
    local public_key="$1"
    local file="$2"

    # NB: The '--in-place' flag must be provided before '--encrypt',
    #     otherwise it is ignored.
    sops --age "$public_key" --in-place --encrypt "$file"
}


# Use 'sops' to decrypt a file using an 'age' key.
#
# This is an adapter function for 'sops' that allows providing the 'age' private
# key as an argument.
#
# Globals:
#   none
# Arguments:
#   $1 - The 'age' private key
#   $2 - The path to the file to decrypt
# Returns:
#   0 - If the file was successfully decrypted
#   1 - If the file could not be decrypted
# Outputs:
#   STDOUT - The decrypted file
#   STDERR - details, on failure
sops::decrypt_with_age() {
    local private_key="$1"
    local file="$2"

    env SOPS_AGE_KEY="$private_key" sops --decrypt "$file"
}

# Use 'sops' to decrypt a file using an 'age' key in place, i.e., overwrite the file
# with the decrypted content.
#
# This is an adapter function for 'sops' that allows providing the 'age' private
# key as an argument.
#
# Globals:
#   none
# Arguments:
#   $1 - The 'age' private key
#   $2 - The path to the file to decrypt
# Returns:
#   0 - If the file was successfully decrypted
#   1 - If the file could not be decrypted
# Outputs:
#   STDERR - details, on failure
sops::decrypt_in_place_with_age() {
    local private_key="$1"
    local file="$2"

    # NB: The '--in-place' flag must be provided before '--decrypt',
    #     otherwise it is ignored.
    env SOPS_AGE_KEY="$private_key" sops --in-place --decrypt "$file"
}
