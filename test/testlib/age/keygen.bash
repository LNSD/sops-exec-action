#!/usr/bin/env bash

bats_load_library 'bats-file'

# Clear the 'age' test library environment variables.
#
# Unsets the following environment variables:
#   - AGE_PUBLIC_KEY
#   - AGE_SECRET_KEY
#   - AGE_KEY_FILE
#
# Globals:
#   AGE_PUBLIC_KEY
#   AGE_SECRET_KEY
#   AGE_KEY_FILE
# Outputs:
#   STDERR - details, on failure
age::unset_env() {
	unset -v AGE_PUBLIC_KEY
	unset -v AGE_SECRET_KEY
	unset -v AGE_KEY_FILE
}


# Use 'age-keygen' to generate a keypair. If no key file is provided, a temporary file will be created.
#
# If the keypair is successfully generated, the following environment variables will be set:
#   - AGE_PUBLIC_KEY: The public key
#   - AGE_SECRET_KEY: The private key
#   - AGE_KEY_FILE: The file containing the private key
#
# Otherwise, the environment variables will not be set.
#
# Globals:
#   AGE_PUBLIC_KEY
#   AGE_SECRET_KEY
#   AGE_KEY_FILE
# Arguments:
#   $1 - The path to the key file (Optional)
# Returns:
#   0 - If the keypair was successfully generated
#   1 - If the keypair could not be generated
# Outputs:
#   STDERR - details, on failure
age::generate_keypair() {
	local key_file
	# If the key file is not provided, create a temporary file
	key_file="${1:-}"
	if [ -z "$key_file" ]; then
		key_file="$(temp_make)/key.age"
	fi

	# Run `age-keygen` to generate a keypair, if the command fails, return 1 and
	# do not set the environment variables
	local public_key
	if ! public_key="$(age-keygen -o "$key_file" 2>&1)"; then
		echo "Keypair generation failed" >&2
		return 1
	fi

	# Extract the public key from the output, return 1 if it could not be found
	public_key="$(echo "$public_key" | grep -oP 'age1[a-z0-9]+')"
	if [ -z "$public_key" ]; then
		echo "Public key could not be found" >&2
		return 1
	fi

	# Extract the private key from the file, return 1 if it could not be found
	local public_key
	private_key="$(cat "$key_file")"
	if [ -z "$private_key" ]; then
		echo "Private key could not be found" >&2
		return 1
	fi

	# Export the environment variables
	export AGE_PUBLIC_KEY="$public_key"
	export AGE_SECRET_KEY="$private_key"
	export AGE_KEY_FILE="$key_file"

	return 0
}
