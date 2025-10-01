#!/usr/bin/env bash

bats_load_library 'bats-file'

# List all keys in the gpg home directory.
#
# The gpg home directory can be provided as an argument or via the GPG_HOME_DIR
# environment variable.
#
# Globals:
#   GPG_HOME_DIR - The path to the gpg home directory
# Arguments:
#   $1 - The gpg home directory (optional)
# Outputs:
#   STDOUT - The list of keys
#   STDERR - details, on failure
gpg::list_keys_debug() {
	local gpg_home_dir
	gpg_home_dir="${1:-$GPG_HOME_DIR}"

	# Ensure the gpg home directory was provided
	if [[ -z "$gpg_home_dir" ]]; then
		echo "No gpg home directory provided" >&2
		return 1
	fi

	# List the keys
	if ! gpg --homedir "$gpg_home_dir" --list-keys; then
		echo "Failed to list keys" >&2
		return 1
	fi
}

# List all keys fingerprints in the gpg home directory.
#
# The gpg home directory can be provided as an argument or via the GPG_HOME_DIR
# environment variable.
#
# Globals:
#   GPG_HOME_DIR - The path to the gpg home directory
# Arguments:
#   $1 - The gpg home directory (optional)
# Outputs:
#   STDOUT - The list of keys fingerprints
#   STDERR - details, on failure
gpg::list_keys_fingerprints() {
	local gpg_home_dir
	gpg_home_dir="${1:-$GPG_HOME_DIR}"

	# Ensure the gpg home directory was provided
	if [[ -z "$gpg_home_dir" ]]; then
		echo "No gpg home directory provided" >&2
		return 1
	fi

	# List the keys
	if ! gpg --homedir "$gpg_home_dir" --with-colons --fingerprint --list-keys | awk -F: '/^fpr:/ {print $10}'; then
		echo "Failed to list keys fingerprints" >&2
		return 1
	fi
}

# Use 'gpg' to import a key.
#
# Supports providing a custom gpg home directory. If not provided, as an argument
# or via the GPG_HOME_DIR environment variable, a temporary directory will be
# created and the path will be exported to the GPG_HOME_DIR environment variable.
#
# Globals:
#   GPG_HOME_DIR - The path to the gpg home directory
# Arguments:
#   $1 - The key to import
#   $2 - The gpg home directory (optional)
# Returns:
#   0 - If the keypair was successfully imported
#   1 - If the keypair could not be imported
# Outputs:
#   STDERR - details, on failure
gpg::import_key() {
	local key
	local gnupg_home
	key="$1"
	gnupg_home="${2:-$GPG_HOME_DIR}"

	# Ensure the key was provided
	if [[ -z "$key" ]]; then
		echo "No key provided" >&2
		return 1
	fi

	# If the gpg home directory is not provided, use a temp directory
	local gpg_home_dir
	local temp_gnupg_home=""
	if [[ -n "$gnupg_home" ]]; then
		gpg_home_dir="$gnupg_home"
	else
		temp_gnupg_home="$(temp_make)"
		gpg_home_dir="$temp_gnupg_home"
	fi

	# Import the keypair
	if ! gpg --homedir "$gpg_home_dir" --batch --import --yes <<<"$key" 2>/dev/null; then
		echo "Keypair import failed" >&2

		# Clean up the temporary directory if it was created
		if [[ -n "$temp_gnupg_home" ]]; then
			temp_del "$temp_gnupg_home"
		fi
		return 1
	fi

	# Export the environment variables
	export GPG_HOME_DIR="$gpg_home_dir"

	return 0
}

# Use 'gpg' to import a key from a file.
#
# Supports providing a custom gpg home directory. If not provided, as an argument
# or via the GPG_HOME_DIR environment variable, a temporary directory will be
# created and the path will be exported to the GPG_HOME_DIR environment variable.
#
# Globals:
#   GPG_HOME_DIR - The path to the gpg home directory
# Arguments:
#   $1 - The path to the key file
#   $2 - The gpg home directory (optional)
# Returns:
#   0 - If the keypair was successfully imported
#   1 - If the keypair could not be imported
# Outputs:
#   STDERR - details, on failure
gpg::import_key_file() {
	local key_file
	local gnupg_home
	key_file="$1"
	gnupg_home="${2:-$GPG_HOME_DIR}"

	# Ensure the key file was provided
	if [[ -z "$key_file" ]]; then
		echo "No key file provided" >&2
		return 1
	fi

	# If the gpg home directory is not provided, use a temp directory
	local gpg_home_dir
	local temp_gnupg_home=""
	if [[ -n "$gnupg_home" ]]; then
		gpg_home_dir="$gnupg_home"
	else
		temp_gnupg_home="$(temp_make)"
		gpg_home_dir="$temp_gnupg_home"
	fi

	# Import the keypair
	if ! gpg --homedir "$gpg_home_dir" --batch --import --yes "$key_file" 2>/dev/null; then
		echo "Keypair import failed" >&2

		# Clean up the temporary directory if it was created
		if [[ -n "$temp_gnupg_home" ]]; then
			temp_del "$temp_gnupg_home"
		fi
		return 1
	fi

	# Export the environment variables
	export GPG_HOME_DIR="$gpg_home_dir"

	return 0
}
