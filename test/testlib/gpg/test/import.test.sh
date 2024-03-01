#!/usr/bin/env bats

setup() {
	# Load test libraries
	bats_load_library 'bats-support'
	bats_load_library 'bats-assert'
	bats_load_library 'bats-file'

	load '../load'
}

# shellcheck disable=SC2030
@test 'gpg::keystore::environment variables should be unset' {
	## Given
	export GPG_HOME_DIR="dir"

	## When
	gpg::unset_env

	## Then
	assert [ -z "$GPG_HOME_DIR" ]
}

@test "gpg::keystore::it should import a key" {
	## Given
	local gpg_home_dir
	gpg_home_dir="$(temp_make)"

	# Generate a keypair
	gpg::generate_keypair

	## When
	gpg::import_key "$GPG_SECRET_KEY" "$gpg_home_dir"

	## Then
	# Assert that the key was successfully imported
	assert [ $? -eq 0 ]

	# Assert that the keypair was imported and it is listed in the keyring
	assert_regex "$(gpg::list_keys_fingerprints "$gpg_home_dir")" "$GPG_KEY_FP"

	## Cleanup
	temp_del "$gpg_home_dir"
}

@test "gpg::keystore::it should import a key file" {
	## Given
	local gpg_home_dir
	gpg_home_dir="$(temp_make)"

	# Generate a keypair
	gpg::generate_keypair

	## When
	gpg::import_key_file "$GPG_KEY_FILE" "$gpg_home_dir"

	## Then
	# Assert that the key file was successfully imported
	assert [ $? -eq 0 ]

	# Assert that the keypair was imported and it is listed in the keyring
	assert_regex "$(gpg::list_keys_fingerprints "$gpg_home_dir")" "$GPG_KEY_FP"

	## Cleanup
	temp_del "$gpg_home_dir"
}
