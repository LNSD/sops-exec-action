#!/usr/bin/env bats

setup() {
	load 'libs/bats-support/load'
	load 'libs/bats-assert/load'

	# Get the containing directory of this file. Use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]}
	# or $0, as those will point to the bats executable's location or the preprocessed file respectively
	DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"

	# Make executables in project root visible to PATH
	PATH="$DIR/..:$PATH"
}

@test "can run action's main" {
	## When
	run action.sh "main"

	## Then
	assert_success
	assert_output "Hello, main!"
}
