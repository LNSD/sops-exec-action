#!/usr/bin/env bats

setup() {
	bats_require_minimum_version 1.10.0

	# Load test libraries
	bats_load_library 'bats-support'
	bats_load_library 'bats-assert'
	bats_load_library 'bats-file'

	load 'testlib/age/load'
	load 'testlib/gpg/load'
	load 'testlib/sops/load'

	# Get the containing directory of this file. Use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]}
	# or $0, as those will point to the bats executable's location or the preprocessed file respectively
	DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"

	# Source the action.sh script
	source "$DIR/../action.sh"
}

@test 'run command with encrypted environment file using age' {
	## Given
	# Integration test key file and environment file
	test_key_file="$DIR/assets/inttest-key.age"
	test_env_file="$DIR/assets/inttest.env"

	## When
	# Do not set any age key environment variables
	export SOPS_AGE_KEY_FILE="$test_key_file"
	run action::main "$test_env_file" "bash -c '[[ \"\$SECRET_KEY\" == \"YOURSECRETKEYGOESHERE\" && \"\$SECRET_HASH\" == \"something-with-a-#-hash\" ]]'"

	## Then
	assert_success
}

@test 'run command with encrypted environment file using gpg' {
	## Setup
	# Create a temporary directory
	local temp_dir
	temp_dir="$(temp_make)"

	# Create a temporary gpg home dir
	local gpg_home_dir="$temp_dir/gpg"
	mkdir -p "$gpg_home_dir"

	## Given
	# Integration test key file and environment file
	test_key_file="$DIR/assets/inttest-key.gpg"
	test_key_fp="0E7149234D1B7D4FB51151F3A592E2998D33FE5D"
	test_env_file="$DIR/assets/inttest.env"

	# Import the test key
	gpg::import_key_file "$test_key_file" "$gpg_home_dir"

	## When
	# Set the gpg home dir and the key environment variable
	export GNUPGHOME="$gpg_home_dir"
	export SOPS_GPG_FP="$test_key_fp"
	run action::main "$test_env_file" "bash -c '[[ \"\$SECRET_KEY\" == \"YOURSECRETKEYGOESHERE\" && \"\$SECRET_HASH\" == \"something-with-a-#-hash\" ]]'"

	## Then
	assert_success

	## Cleanup
	# Remove the temporary directory
	temp_del "$temp_dir"
}
