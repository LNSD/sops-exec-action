#!/usr/bin/env bats

setup() {
	bats_require_minimum_version 1.5.0

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

@test 'run command with encrypted environment file' {
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
