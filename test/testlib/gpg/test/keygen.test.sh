#!/usr/bin/env bats

setup() {
	# Load test libraries
	bats_load_library 'bats-support'
	bats_load_library 'bats-assert'
	bats_load_library 'bats-file'

	load '../load'
}

# shellcheck disable=SC2030
@test 'gpg::keygen::environment variables should be unset' {
	## Given
	export GPG_KEY_EMAIL="email"
	export GPG_KEY_FP="fp"
	export GPG_PUBLIC_KEY="public"
	export GPG_SECRET_KEY="secret"
	export GPG_KEY_FILE="file"

	## When
	gpg::unset_env

	## Then
	assert [ -z "$GPG_KEY_EMAIL" ]
	assert [ -z "$GPG_KEY_FP" ]
	assert [ -z "$GPG_PUBLIC_KEY" ]
	assert [ -z "$GPG_SECRET_KEY" ]
	assert [ -z "$GPG_KEY_FILE" ]
}

# shellcheck disable=SC2031
@test "gpg::keygen::it should generate a keypair in a tmp directory" {
	## When
	gpg::generate_keypair

	## Then
	# Assert that the keypair was generated
	assert [ $? -eq 0 ]

	# Assert that the environment variables are set
	assert [ -n "$GPG_KEY_EMAIL" ]
	assert [ -n "$GPG_KEY_FP" ]
	assert [ -n "$GPG_PUBLIC_KEY" ]
	assert [ -n "$GPG_SECRET_KEY" ]
	assert [ -n "$GPG_KEY_FILE" ]

	# Assert that the key file exists
	assert_exists "$GPG_KEY_FILE"

	## Cleanup
	temp_del "$(dirname "$GPG_KEY_FILE")"
}

# shellcheck disable=SC2031
@test "gpg::keygen::it should generate a keypair in a specified file" {
	## Given
	key_file="$(temp_make)/key.gpg"

	## When
	gpg::generate_keypair "$key_file"

	## Then
	# Assert that the keypair was generated
	assert [ $? -eq 0 ]

	# Assert that the environment variables are set
	assert [ -n "$GPG_KEY_EMAIL" ]
	assert [ -n "$GPG_KEY_FP" ]
	assert [ -n "$GPG_PUBLIC_KEY" ]
	assert [ -n "$GPG_SECRET_KEY" ]
	assert [ -n "$GPG_KEY_FILE" ]

	# Assert that the key file exists
	assert_exists "$GPG_KEY_FILE"

	## Cleanup
	temp_del "$(dirname "$key_file")"
}
