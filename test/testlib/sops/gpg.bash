#!/usr/bin/env bash
## SOPS adapter functions using 'gpg' for encryption and decryption.

# Use 'sops' to encrypt a file using an 'gpg' key.
#
# This is an adapter function for 'sops' that allows providing the 'gpg' key
# fingerprint as an argument.
#
# The 'gpg' key must be in the keyring.
#
# The 'gpg' home directory can be provided as an optional argument or it can be
# set via the 'GPG_HOME_DIR' environment variable.
#
# Globals:
#   GPG_HOME_DIR - The path to the gpg home directory
# Arguments:
#   $1 - The 'gpg' public key
#   $2 - The path to the file to encrypt
#   $3 - The gpg home directory (optional)
# Returns:
#   0 - If the file was successfully encrypted
#   1 - If the file could not be encrypted
# Outputs:
#   STDOUT - The encrypted file
#   STDERR - details, on failure
sops::encrypt_with_gpg() {
	local public_key="$1"
	local file="$2"
	local gpg_home_dir="${3:-$GPG_HOME_DIR}"

	env GNUPGHOME="$gpg_home_dir" sops --pgp "$public_key" --encrypt "$file"
}

# Use 'sops' to encrypt a file using an 'gpg' key in place, i.e., overwrite the file
# with the encrypted content.
#
# This is an adapter function for 'sops' that allows providing the 'gpg' public
# key as an argument.
#
# The 'gpg' key must be in the keyring.
#
# The 'gpg' home directory can be provided as an optional argument or it can be set
# via the 'GPG_HOME_DIR' environment variable.
#
# Globals:
#   GPG_HOME_DIR - The path to the gpg home directory
# Arguments:
#   $1 - The 'gpg' key fingerprint
#   $2 - The path to the file to encrypt
#   $3 - The gpg home directory (optional)
# Returns:
#   0 - If the file was successfully encrypted
#   1 - If the file could not be encrypted
# Outputs:
#   STDERR - details, on failure
sops::encrypt_in_place_with_gpg() {
	local fingerprint="$1"
	local file="$2"
	local gpg_home_dir="${3:-$GPG_HOME_DIR}"

	# NB: The '--in-place' flag must be provided before '--encrypt',
	#     otherwise it is ignored.
	env GNUPGHOME="$gpg_home_dir" sops --pgp "$fingerprint" --in-place --encrypt "$file"
}

# Use 'sops' to decrypt a file using an 'gpg' key.
#
# This is an adapter function for 'sops' that allows providing the 'gpg' private
# key as an argument.
#
# The 'gpg' key must be in the keyring.
#
# The 'gpg' home directory can be provided as an optional argument or it can be
# set via the 'GPG_HOME_DIR' environment variable.

# Globals:
#   GPG_HOME_DIR - The path to the gpg home directory
# Arguments:
#   $1 - The 'gpg' key fingerprint
#   $2 - The path to the file to decrypt
#   $3 - The gpg home directory (optional)
# Returns:
#   0 - If the file was successfully decrypted
#   1 - If the file could not be decrypted
# Outputs:
#   STDOUT - The decrypted file
#   STDERR - details, on failure
sops::decrypt_with_gpg() {
	local fingerprint="$1"
	local file="$2"
	local gpg_home_dir="${3:-$GPG_HOME_DIR}"

	env GNUPGHOME="$gpg_home_dir" sops --pgp "$fingerprint" --decrypt "$file"
}

# Use 'sops' to decrypt a file using an 'gpg' key in place, i.e., overwrite the file
# with the decrypted content.
#
# This is an adapter function for 'sops' that allows providing the 'gpg' private
# key as an argument.
#
# The 'gpg' key must be in the keyring.
#
# The 'gpg' home directory can be provided as an optional argument or it can be set
# via the 'GPG_HOME_DIR' environment variable.
#
# Globals:
#	GPG_HOME_DIR - The path to the gpg home directory
# Arguments:
#   $1 - The 'gpg' key fingerprint
#   $2 - The path to the file to decrypt
#   $3 - The gpg home directory (optional)
# Returns:
#   0 - If the file was successfully decrypted
#   1 - If the file could not be decrypted
# Outputs:
#   STDERR - details, on failure
sops::decrypt_in_place_with_gpg() {
	local fingerprint="$1"
	local file="$2"
	local gpg_home_dir="${3:-$GPG_HOME_DIR}"

	# NB: The '--in-place' flag must be provided before '--decrypt',
	#     otherwise it is ignored.
	env GNUPGHOME="$gpg_home_dir" sops --pgp "$fingerprint" --in-place --decrypt "$file"
}
