#!/usr/bin/env bash

bats_load_library 'bats-file'

# Clear the 'gpg' test library environment variables.
#
# Unsets the following environment variables:
#   - GPG_KEY_EMAIL
#   - GPG_KEY_FP
#   - GPG_PUBLIC_KEY
#   - GPG_SECRET_KEY
#   - GPG_KEY_FILE
#	- GPG_HOME_DIR
#
# Globals:
#	GPG_KEY_EMAIL
#	GPG_KEY_FP
#	GPG_PUBLIC_KEY
#	GPG_SECRET_KEY
#	GPG_KEY_FILE
#	GPG_HOME_DIR
# Outputs:
#   STDERR - details, on failure
gpg::unset_env() {
	unset -v GPG_KEY_EMAIL
	unset -v GPG_KEY_FP
	unset -v GPG_PUBLIC_KEY
	unset -v GPG_SECRET_KEY
	unset -v GPG_KEY_FILE
	unset -v GPG_HOME_DIR
}
