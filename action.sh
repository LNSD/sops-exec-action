#!/usr/bin/env bash

# Use 'sops' to decrypt a file using an encryption key and pass the secrets to
# the given command.
#
# The encryption key information must be provided via environment variables:
# - SOPS_AGE_KEY_FILE (or SOPS_AGE_KEY) - The 'age' key to use for decryption.
# - SOPS_GPG_FP - The GnuPG key fingerprint to use for decryption.
#
# NB: The "command" will be executed by sops as a sub-process: `/bin/sh -c "$command"`.
# See: https://github.com/getsops/sops/blob/d8e8809bf92a47e0b2f742b9a43c3ab713acfd6a/cmd/sops/subcommand/exec/exec_unix.go#L14-L16
#
# If the command fails, the error code will be propagated by 'sops', and it will print
# an additional 'exit status <status-code>' message to STDOUT.
#
# Globals:
#   SOPS_AGE_KEY_FILE or SOPS_AGE_KEY - The 'age' key to use for decryption.
#   SOPS_GPG_FP (and optionally GNUPGHOME) - The GPG key to use for decryption.
# Arguments:
#   $1 - The path to the file to decrypt.
#   $2 - The command to execute.
# Returns:
#   0 - If the command was successfully executed.
#   1 - If the command could not be executed.
# Outputs:
#   STDOUT - The output of the command
#   STDERR - details, on failure
_sops::exec_env() {
  local env_file=$1
  local command=$2

  sops exec-env "$env_file" "$command"
}

# The pre-requisite checks for the action.
#
# Check if the decryption keys have been provided and if the required tools are installed.
#
# Returns:
#   0 - If all pre-requisites are met.
#   1 - If a pre-requisite is not met.
# Action Outputs:
#   age-version - The version of age installed.
#   gpg-version - The version of gpg installed.
#   sops-version - The version of sops installed.
action::check_pre_requisites() {

	# Check if any of the 'age' or 'gpg' keys environment variables are set
	if [[ -z "$SOPS_AGE_KEY_FILE" ]] && [[ -z "$SOPS_AGE_KEY" ]] && [[ -z "$SOPS_GPG_FP" ]]; then
		echo "Decryption key not specified: SOPS_AGE_KEY_FILE, SOPS_AGE_KEY or SOPS_GPG_FP" >&2
		return 1
	fi

	# Check if 'gpg' is installed and get the version
	local gpg_version
	if ! command -v gpg &> /dev/null; then
		gpg_version="none"
	else
		gpg_version="$(gpg --version | awk 'NR==1{print $3}')"
	fi

	# Fail if the 'gpg' fingerprint is set and 'gpg' is not installed
	if [[ -n "$SOPS_GPG_FP" && "$gpg_version" == 'none' ]]; then
		echo "gpg not found in PATH. Please install gpg." >&2
		return 1
	fi

	# Check if 'age' is installed and get the version
	local age_version
	if ! command -v age &> /dev/null; then
		age_version="none"
	else
		age_version="$(age --version | sed 's/^v//')"
	fi

	# Write the 'age' version to a GitHub output variable
	echo "age-version=$age_version" >> "$GITHUB_OUTPUT"

	# Fail if the 'age' key is set and 'age' is not installed
	if [[ -n "$SOPS_AGE_KEY_FILE" || -n "$SOPS_AGE_KEY" ]] && [[ "$age_version" == 'none' ]]; then
		echo "age not found in PATH. Please install age." >&2
		return 1
	fi

	# Fail if 'sops' is not installed
	local sops_version
	if ! command -v sops &> /dev/null; then
		echo "sops not found in PATH. Please install sops." >&2
		return 1
	else
		sops_version="$(sops --disable-version-check --version | awk '{print $2}')"
	fi

	# Write the version as GitHub output variables
	{ echo "gpg-version=$gpg_version"; echo "age-version=$age_version"; echo "sops-version=$sops_version"; } >> "$GITHUB_OUTPUT"
}

# The entrypoint for the action.
action::main() {
  local env_file=$1
  local command=$2

  # Check if file exists
  if [[ ! -f "$env_file" ]]; then
	echo "Environment file not found: $env_file" >&2
	return 1
  fi

  # Decrypt and inject the environment variables to the command
  _sops::exec_env "$env_file" "$command"
}
