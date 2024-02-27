#!/usr/bin/env bash

# Use 'sops' to decrypt a file using an 'age' key and pass the secrets to
# the given command.
#
# NB: The "command" will be executed by sops as a sub-process: `/bin/sh -c "$command"`.
# See: https://github.com/getsops/sops/blob/d8e8809bf92a47e0b2f742b9a43c3ab713acfd6a/cmd/sops/subcommand/exec/exec_unix.go#L14-L16
#
# If the command fails, the error code will be propagated by 'sops', and it will print
# an additional 'exit status <status-code>' message to STDOUT.
#
# Globals:
#   SOPS_AGE_KEY_FILE or SOPS_AGE_KEY
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
# Returns:
#   0 - If all pre-requisites are met.
#   1 - If a pre-requisite is not met.
# Action Outputs:
#   age-version - The version of age installed.
#   sops-version - The version of sops installed.
action::check_pre_requisites() {
	# Check if age is installed
	if ! command -v age &> /dev/null; then
		echo "age not found in PATH. Please install age." >&2
		return 1
	fi

	# Write the age version to a GitHub output variable
	echo "age-version=$(age --version)" >> "$GITHUB_OUTPUT"

	# Check if sops is installed
	if ! command -v sops &> /dev/null; then
		echo "sops not found in PATH. Please install sops." >&2
		return 1
	fi

	# Write the sops version to a GitHub output variable
	echo "sops-version=$(sops --version)" >> "$GITHUB_OUTPUT"
}

# The entrypoint for the action.
action::main() {
  local env_file=$1
  local command=$2

  # Check if file exists
  if [ ! -f "$env_file" ]; then
	echo "Environment file not found: $env_file" >&2
	return 1
  fi

  # Check if any of the 'age' key environment variables are set
  if [ -z "$SOPS_AGE_KEY_FILE" ] && [ -z "$SOPS_AGE_KEY" ]; then
  		echo "Decryption key not set: SOPS_AGE_KEY_FILE or SOPS_AGE_KEY" >&2
  		return 1
  fi

  # Decrypt and inject the environment variables to the command
  _sops::exec_env "$env_file" "$command"
}
