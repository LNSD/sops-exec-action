#!/usr/bin/env bats

setup() {
	# Load test libraries
	bats_load_library 'bats-support'
	bats_load_library 'bats-assert'
	bats_load_library 'bats-file'

	load '../load'
}

# shellcheck disable=SC2030
@test 'age::keygen::environment variables should be unset' {
	## Given
	export AGE_PUBLIC_KEY="public"
	export AGE_SECRET_KEY="secret"
	export AGE_KEY_FILE="file"

	## When
	age::unset_env

	## Then
	assert [ -z "$AGE_PUBLIC_KEY" ]
	assert [ -z "$AGE_SECRET_KEY" ]
	assert [ -z "$AGE_KEY_FILE" ]
}

# shellcheck disable=SC2031
@test "age::keygen::it should generate a keypair in a tmp directory" {
	## When
	age::generate_keypair

	## Then
	# Assert that the keypair was generated
	assert [ $? -eq 0 ]

	# Assert that the environment variables are set
	assert [ -n "$AGE_PUBLIC_KEY" ]
	assert [ -n "$AGE_SECRET_KEY" ]
	assert [ -n "$AGE_KEY_FILE" ]

	# Assert that the key file exists
	assert_exists "$AGE_KEY_FILE"

	## Cleanup
	temp_del "$(dirname $AGE_KEY_FILE)"
}

# shellcheck disable=SC2031
@test "age::keygen::it should generate a keypair in a specified file" {
	## Given
	key_file="$(temp_make)/key.age"

	## When
	age::generate_keypair "$key_file"

	## Then
	# Assert that the keypair was generated
	assert [ $? -eq 0 ]

	# Assert that the environment variables are set
	assert [ -n "$AGE_PUBLIC_KEY" ]
	assert [ -n "$AGE_SECRET_KEY" ]
	assert [ -n "$AGE_KEY_FILE" ]

	# Assert that the key file exists
	assert_exists "$AGE_KEY_FILE"

	## Cleanup
	temp_del "$(dirname $AGE_KEY_FILE)"
}
