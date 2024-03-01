#!/usr/bin/env bats

setup() {
	bats_require_minimum_version 1.5.0

	# Load test libraries
	bats_load_library 'bats-support'
	bats_load_library 'bats-assert'
	bats_load_library 'bats-file'

	load 'testlib/gpg/load'
	load 'testlib/sops/load'

	# Get the containing directory of this file. Use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]}
	# or $0, as those will point to the bats executable's location or the preprocessed file respectively
	DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"

	# Source the action.sh script
	source "$DIR/../action.sh"
}


@test 'action::gpg::exec command with environment' {
	## Setup
	# Create a temporary directory
	local temp_dir
	temp_dir="$(temp_make)"

	# Create a new gnupg home directory
	local gpg_home_dir="$temp_dir/gpg"
	mkdir -p "$gpg_home_dir"

	## Given
	# Create a new test environment file.
	local env_file="$temp_dir/.env"

	cat <<-EOF > "$env_file"
	SECRET_KEY=YOURSECRETKEYGOESHERE
	SECRET_HASH=something-with-a-#-hash
	EOF

	# Define the test command
	local test_command
	# shellcheck disable=SC2016
	test_command='printf "SECRET_KEY: \"$SECRET_KEY\"\nSECRET_HASH: \"$SECRET_HASH\""'

	# Generate a new gpg keypair, import the public key and encrypt the environment file
	gpg::generate_keypair "$temp_dir/key.gpg"
	gpg::import_key_file "$temp_dir/key.gpg" "$gpg_home_dir"

	sops::encrypt_in_place_with_gpg "$GPG_KEY_FP" "$env_file" "$gpg_home_dir"

	## When
	# Set the gpg home and key fingerprint environment variables
	export GNUPGHOME="$gpg_home_dir"
	export SOPS_GPG_FP="$GPG_KEY_FP"

	run --separate-stderr action::main "$env_file" "$test_command; exit 0"

	## Then
	assert_success
	assert_line --index 0 'SECRET_KEY: "YOURSECRETKEYGOESHERE"'
	assert_line --index 1 'SECRET_HASH: "something-with-a-#-hash"'

	# Assert that the secret environment variables are not exposed
	assert [ -z "$SECRET_KEY" ]
	assert [ -z "$SECRET_HASH" ]

	## Cleanup
	# Remove the temporary directory
	temp_del "$temp_dir"
}

@test 'action::gpg::exec command with environment and fail with non-zero exit code' {
	## Setup
	# Create a temporary directory
	local temp_dir
	temp_dir="$(temp_make)"

	# Create a new gnupg home directory
	local gpg_home_dir="$temp_dir/gpg"
	mkdir -p "$gpg_home_dir"

	## Given
	# Create a new test environment file.
	local env_file="$temp_dir/.env"

	cat <<-EOF > "$env_file"
	SECRET_KEY=YOURSECRETKEYGOESHERE
	SECRET_HASH=something-with-a-#-hash
	EOF

	# Define the test command
	local test_command
	# shellcheck disable=SC2016
	test_command='printf "SECRET_KEY: \"$SECRET_KEY\"\nSECRET_HASH: \"$SECRET_HASH\""'

	# Generate a new gpg keypair, import it and encrypt the environment file
	gpg::generate_keypair "$temp_dir/key.gpg"
	gpg::import_key_file "$temp_dir/key.gpg" "$gpg_home_dir"

	sops::encrypt_in_place_with_gpg "$GPG_KEY_FP" "$env_file" "$gpg_home_dir"

	## When
	# Set the gpg home and key fingerprint environment variables
	export GNUPGHOME="$gpg_home_dir"
	export SOPS_GPG_FP="$GPG_KEY_FP"

	run --separate-stderr action::main "$env_file" "$test_command; exit 55"

	## Then
	assert_failure 55
	assert_line --index 0 'SECRET_KEY: "YOURSECRETKEYGOESHERE"'
	assert_line --index 1 'SECRET_HASH: "something-with-a-#-hash"'

	# Assert that the secret environment variables are not exposed
	assert [ -z "$SECRET_KEY" ]
	assert [ -z "$SECRET_HASH" ]

	## Cleanup
	# Remove the temporary directory
	temp_del "$temp_dir"
}

@test 'action::gpg::exec command with non-encrypted environment file' {
	## Setup
	# Create a temporary directory
	local temp_dir
	temp_dir="$(temp_make)"

	# Create a new gnupg home directory
	local gpg_home_dir="$temp_dir/gpg"
	mkdir -p "$gpg_home_dir"

	## Given
	# Create a new test environment file.
	local env_file="$temp_dir/.env"

	cat <<-EOF > "$env_file"
	SECRET_KEY=YOURSECRETKEYGOESHERE
	SECRET_HASH=something-with-a-#-hash
	EOF

	# Define the test command
	local test_command
	# shellcheck disable=SC2016
	test_command='printf "SECRET_KEY: \"$SECRET_KEY\"\nSECRET_HASH: \"$SECRET_HASH\""'

	# Generate a new gpg keypair, import it and encrypt the environment file
	gpg::generate_keypair "$temp_dir/key.gpg"
	gpg::import_key_file "$temp_dir/key.gpg" "$gpg_home_dir"

	sops::encrypt_in_place_with_gpg "$GPG_KEY_FP" "$env_file" "$gpg_home_dir"

	## When
	# Set the gpg home and key fingerprint environment variables
	export GNUPGHOME="$gpg_home_dir"
	export SOPS_GPG_FP="$GPG_KEY_FP"

	run --separate-stderr action::main "$env_file" "$test_command; exit 45"

	## Then
	assert_failure 45
	assert_line --index 0 'SECRET_KEY: "YOURSECRETKEYGOESHERE"'
	assert_line --index 1 'SECRET_HASH: "something-with-a-#-hash"'

	# Assert that the secret environment variables are not exposed
	assert [ -z "$SECRET_KEY" ]
	assert [ -z "$SECRET_HASH" ]

	## Cleanup
	# Remove the temporary directory
	temp_del "$temp_dir"
}


