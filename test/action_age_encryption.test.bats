#!/usr/bin/env bats

setup() {
	bats_require_minimum_version 1.10.0

	# Load test libraries
	bats_load_library 'bats-support'
	bats_load_library 'bats-assert'
	bats_load_library 'bats-file'

	load 'testlib/age/load'
	load 'testlib/sops/load'

	# Get the containing directory of this file. Use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]}
	# or $0, as those will point to the bats executable's location or the preprocessed file respectively
	DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"

	# Source the action.sh script
	source "$DIR/../action.sh"
}

@test 'action::age::exec command with environment' {
	## Given
	# Create a temporary directory
	local temp_dir
	temp_dir="$(temp_make)"

	# Create a new test environment file.
	local env_file
	env_file="$temp_dir/.env"

	cat <<-EOF >"$env_file"
		SECRET_KEY=YOURSECRETKEYGOESHERE
		SECRET_HASH=something-with-a-#-hash
	EOF

	# Define the test command
	local test_command
	# shellcheck disable=SC2016
	test_command='printf "SECRET_KEY: \"$SECRET_KEY\"\nSECRET_HASH: \"$SECRET_HASH\""'

	# Generate a new age keypair and encrypt the environment file
	age::generate_keypair "$temp_dir/key.age"
	sops::encrypt_in_place_with_age "$AGE_PUBLIC_KEY" "$env_file"

	## When
	# Set the age key environment variable
	export SOPS_AGE_KEY="$AGE_SECRET_KEY"

	run --separate-stderr action::main "$env_file" "$test_command; exit 0"

	## Then
	assert_success
	assert_line --index 0 'SECRET_KEY: "YOURSECRETKEYGOESHERE"'
	assert_line --index 1 'SECRET_HASH: "something-with-a-#-hash"'

	# Assert that the secret environment variables are not exposed
	assert [ -z "$SECRET_KEY" ]
	assert [ -z "$SECRET_HASH" ]

	## Clean
	# Remove the temporary directory
	temp_del "$temp_dir"
}

@test 'action::age::exec command with environment and age key file' {
	## Given
	# Create a temporary directory
	local temp_dir
	temp_dir="$(temp_make)"

	# Create a new test environment file.
	local env_file
	env_file="$temp_dir/.env"

	cat <<-EOF >"$env_file"
		SECRET_KEY=YOURSECRETKEYGOESHERE
		SECRET_HASH=something-with-a-#-hash
	EOF

	# Define the test command
	local test_command
	# shellcheck disable=SC2016
	test_command='printf "SECRET_KEY: \"$SECRET_KEY\"\nSECRET_HASH: \"$SECRET_HASH\""'

	# Generate a new age keypair and encrypt the environment file
	age::generate_keypair "$temp_dir/key.age"
	sops::encrypt_in_place_with_age "$AGE_PUBLIC_KEY" "$env_file"

	## When
	# Set the age key file environment variable
	export SOPS_AGE_KEY_FILE="$AGE_KEY_FILE"

	run --separate-stderr action::main "$env_file" "$test_command; exit 0"

	## Then
	assert_success
	assert_line --index 0 'SECRET_KEY: "YOURSECRETKEYGOESHERE"'
	assert_line --index 1 'SECRET_HASH: "something-with-a-#-hash"'

	# Assert that the secret environment variables are not exposed
	assert [ -z "$SECRET_KEY" ]
	assert [ -z "$SECRET_HASH" ]

	## Clean
	# Remove the temporary directory
	temp_del "$temp_dir"
}

@test 'action::age::exec command with environment and fail with non-zero exit code' {
	## Given
	# Create a temporary directory
	local temp_dir
	temp_dir="$(temp_make)"

	# Create a new test environment file.
	local env_file
	env_file="$temp_dir/.env"

	cat <<-EOF >"$env_file"
		SECRET_KEY=YOURSECRETKEYGOESHERE
		SECRET_HASH=something-with-a-#-hash
	EOF

	# Define the test command
	local test_command
	# shellcheck disable=SC2016
	test_command='printf "SECRET_KEY: \"$SECRET_KEY\"\nSECRET_HASH: \"$SECRET_HASH\""'

	# Generate a new age keypair and encrypt the environment file
	age::generate_keypair "$temp_dir/key.age"
	sops::encrypt_in_place_with_age "$AGE_PUBLIC_KEY" "$env_file"

	## When
	# Set the age key environment variable
	export SOPS_AGE_KEY="$AGE_SECRET_KEY"

	run --separate-stderr action::main "$env_file" "$test_command; exit 55"

	## Then
	assert_failure 55
	assert_line --index 0 'SECRET_KEY: "YOURSECRETKEYGOESHERE"'
	assert_line --index 1 'SECRET_HASH: "something-with-a-#-hash"'

	# Assert that the secret environment variables are not exposed
	assert [ -z "$SECRET_KEY" ]
	assert [ -z "$SECRET_HASH" ]

	## Clean
	# Remove the temporary directory
	temp_del "$temp_dir"
}

@test 'action::age::exec command with non-encrypted environment file' {
	## Given
	# Create a temporary directory
	local temp_dir
	temp_dir="$(temp_make)"

	# Create a new test environment file.
	local env_file
	env_file="$temp_dir/.env"

	cat <<-EOF >"$env_file"
		SECRET_KEY=YOURSECRETKEYGOESHERE
		SECRET_HASH=something-with-a-#-hash
	EOF

	# Define the test command
	local test_command
	# shellcheck disable=SC2016
	test_command='printf "SECRET_KEY: \"$SECRET_KEY\"\nSECRET_HASH: \"$SECRET_HASH\""'

	# Generate a new age keypair and encrypt the environment file
	age::generate_keypair "$temp_dir/key.age"
	sops::encrypt_in_place_with_age "$AGE_PUBLIC_KEY" "$env_file"

	## When
	# Set the age key environment variable
	export SOPS_AGE_KEY="$AGE_SECRET_KEY"

	run --separate-stderr action::main "$env_file" "$test_command; exit 45"

	## Then
	assert_failure 45
	assert_line --index 0 'SECRET_KEY: "YOURSECRETKEYGOESHERE"'
	assert_line --index 1 'SECRET_HASH: "something-with-a-#-hash"'

	# Assert that the secret environment variables are not exposed
	assert [ -z "$SECRET_KEY" ]
	assert [ -z "$SECRET_HASH" ]

	## Clean
	# Remove the temporary directory
	temp_del "$temp_dir"
}
