#!/usr/bin/env bash

bats_load_library 'bats-file'

# Use 'gpg' to generate a keypair. If no key file is provided, a temporary file will be created.
#
# If the keypair is successfully generated, the following environment variables will be set:
#   - GPG_KEY_EMAIL: The email address of the keypair
#   - GPG_KEY_FP: The fingerprint of the keypair
#   - GPG_PUBLIC_KEY: The public key of the keypair
#   - GPG_SECRET_KEY: The private key of the keypair
#   - GPG_KEY_FILE: The path to the key file
#
# Otherwise, the environment variables will not be set.
#
# Globals:
#  GPG_KEY_EMAIL
#  GPG_KEY_FP
#  GPG_PUBLIC_KEY
#  GPG_SECRET_KEY
#  GPG_KEY_FILE
# Arguments:
#   $1 - The path to the key file (Optional)
# Returns:
#   0 - If the keypair was successfully generated
#   1 - If the keypair could not be generated
# Outputs:
#   STDERR - details, on failure
gpg::generate_keypair() {
	local key_file
	key_file="${1:-}"

	# If the key file is not provided, create a temporary file
	local key_dir
	if [ -z "$key_file" ]; then
		key_dir="$(temp_make)"
		key_file="$key_dir/key.gpg"
	else
		key_dir="$(dirname "$key_file")"
	fi

	local gnupg_home
	gnupg_home="$(temp_make)"

	# Generate a OpenPGP key pair
	local user_id
	local user_name
	local user_email
	user_id="$RANDOM"
	user_name="Test User $user_id"
	user_email="test-$user_id@example.com"

	cat <<-EOF > "$gnupg_home/keygen_details"
	%echo Generating a test OpenPGP key
	Key-Type: RSA
	Key-Length: 4096
	Subkey-Type: RSA
	Subkey-Length: 4096
	Name-Real: ${user_name}
	Name-Comment: with no passphrase
	Name-Email: ${user_email}
	Expire-Date: 0
	%no-ask-passphrase
	%no-protection
	# Do a commit here, so that we can later print "done"
	%commit
	%echo done
	EOF
	if ! gpg --homedir "$gnupg_home" --verbose --batch --gen-key "$gnupg_home/keygen_details" 2> /dev/null; then
		echo "Keypair generation failed" >&2
		temp_del "$gnupg_home"
		return 1
	fi

	# Export the public and private keys
	local fingerprint
	fingerprint=$(gpg --homedir "$gnupg_home" --fingerprint --with-fingerprint --with-colons "$user_email" | awk -F: '/fpr:/ {print $10; exit}')

	local public_key
	local private_key
	public_key=$(gpg --homedir "$gnupg_home" --armor --export "$user_email")
	private_key=$(gpg --homedir "$gnupg_home" --armor --export-secret-keys "$user_email")


	# Export the private key to a file
	gpg --homedir "$gnupg_home" --armor --export-secret-keys --output "$key_file" "$user_email"

	# Export the environment variables
	export GPG_KEY_EMAIL="$user_email"
	export GPG_KEY_FP="$fingerprint"
	export GPG_PUBLIC_KEY="$public_key"
	export GPG_SECRET_KEY="$private_key"
	export GPG_KEY_FILE="$key_file"

	# Cleanup the temporary files
	temp_del "$gnupg_home"

	return 0
}
