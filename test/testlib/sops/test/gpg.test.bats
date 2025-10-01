#!/usr/bin/env bats

setup() {
	# Load test libraries
	bats_load_library 'bats-support'
	bats_load_library 'bats-assert'
	bats_load_library 'bats-file'

	bats_load_library 'gpg'
	load '../load'
}

# Create a environment test file in the specified destination.
#
# Globals:
# 	none
# Arguments:
#	$1 - The destination file.
function new_test_env_file() {
	local dest_file="$1"

	cat <<-EOF >"$dest_file"
		# This is a comment
		SECRET_KEY=YOURSECRETKEYGOESHERE # comment
		SECRET_HASH="something-with-a-#-hash"
	EOF
}

# Assert that the file is encrypted using 'sops'.
#
# Globals:
#	none
# Arguments:
#	$1 - The file to check
function assert_file_is_encrypted() {
	local file="$1"

	# Check if the file contains the following line: 'sops_version=<semver>'
	if ! grep -q "sops_version=" "$file"; then
		fail "The file is not encrypted"
	fi

	# The file should contain the following line: 'ENC[AES256_GCM,data:...]'
	if ! grep -q "ENC\[AES256_GCM,data:" "$file"; then
		fail "The file is not encrypted"
	fi

	return 0
}

# Assert that the file is not encrypted.
#
# Globals:
#	none
# Arguments:
#	$1 - The file to check
function assert_file_is_not_encrypted() {
	local file="$1"

	# Check if the file contains the following line: 'sops_version=<semver>'
	if grep -q "sops_version=" "$file"; then
		fail "The file is encrypted"
	fi

	# The file should contain the following line: 'ENC[AES256_GCM,data:...]'
	if grep -q "ENC\[AES256_GCM,data:" "$file"; then
		fail "The file is encrypted"
	fi

	return 0
}

@test 'sops::files::it should encrypt the environment file' {
	## Setup
	local temp_dir
	temp_dir="$(temp_make)"

	## Given
	# Create a new test environment file.
	local env_file
	env_file="$temp_dir/.env"
	new_test_env_file "$env_file"

	# Create a new gpg keypair.
	gpg::generate_keypair "$temp_dir/key.gpg"

	# Create a new gpg homedir
	local gpg_home_dir="$temp_dir/gpg"
	mkdir -p "$gpg_home_dir"

	# Import the key into the gpg's keyring
	gpg::import_key_file "$temp_dir/key.gpg" "$gpg_home_dir"

	## When
	local encrypted_file
	encrypted_file="$env_file.encrypted"

	sops::encrypt_with_gpg "$GPG_KEY_FP" "$env_file" "$gpg_home_dir" >"$encrypted_file"

	## Then
	assert [ $? -eq 0 ]
	assert_file_exists "$encrypted_file"
	assert_file_is_encrypted "$encrypted_file"

	## Cleanup
	temp_del "$temp_dir"
}

@test 'sops::files::it should decrypt the environment file' {
	## Setup
	local temp_dir
	temp_dir="$(temp_make)"

	## Given
	# Create a new test environment file.
	local env_file
	env_file="$temp_dir/.env"
	new_test_env_file "$env_file"

	# Create a new gpg keypair.
	gpg::generate_keypair "$temp_dir/key.gpg"

	# Create a new gpg homedir
	local gpg_home_dir="$temp_dir/gpg"
	mkdir -p "$gpg_home_dir"

	# Import the key into the gpg's keyring
	gpg::import_key_file "$temp_dir/key.gpg" "$gpg_home_dir"

	# Encrypt the environment file.
	sops::encrypt_in_place_with_gpg "$GPG_KEY_FP" "$env_file"

	## When
	local decrypted_file
	decrypted_file="$env_file.decrypted"
	sops::decrypt_with_gpg "$GPG_SECRET_KEY" "$env_file" "$gpg_home_dir" >"$decrypted_file"

	## Then
	assert [ $? -eq 0 ]
	assert_file_exists "$decrypted_file"
	assert_file_is_not_encrypted "$decrypted_file"

	## Cleanup
	temp_del "$temp_dir"
}
