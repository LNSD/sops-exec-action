# Justfile for sops-exec-action
# Default recipe - list all available recipes
default:
    @just --list

# Variables
SHELLCHECK := "shellcheck"
YAMLLINT := "yamllint"
BATS := "bats"

# Set the BATS_LIB_PATH environment variable to where the Bats libraries are installed:
#  - Arch Linux: '/usr/lib/bats`
#  - macOS:      '/usr/local/opt'
#  - GHA (using `bats-core/bats-action`): '/usr/lib'
#
# It should also include the testlib directory.
BATS_LIB_PATH := "/usr/lib/bats:/usr/lib:/usr/local/opt:" + justfile_directory() + "/test/testlib"


# Run all available checks and tests
all: check test

# ---- Check recipes ----

# Run all available static checks
check: shellcheck yamllint

# Lint shell scripts (via shellcheck)
shellcheck:
    @echo "Linting shell scripts..."
    @{{SHELLCHECK}} -x -s bash action.sh

# Lint YAML files (via yamllint)
yamllint:
    @echo "Linting YAML files..."
    @{{YAMLLINT}} action.yaml

# Lint testlib shell scripts (via shellcheck)
check-testlib:
    @echo "Linting testlib shell scripts..."
    @{{SHELLCHECK}} -x -s bash test/testlib/**/*.bash

# ---- Test recipes ----

# Run all available tests
test: unittest inttest

# Run unit tests
unittest:
    @echo "Running unit tests..."
    @env BATS_LIB_PATH={{BATS_LIB_PATH}} {{BATS}} --jobs $(nproc) test/*.test.bats

# Run integration tests
inttest:
    @echo "Running integration tests..."
    @env BATS_LIB_PATH={{BATS_LIB_PATH}} {{BATS}} --jobs $(nproc) test/*.inttest.bats

# Run testlib tests
test-testlib:
    @echo "Running testlib tests..."
    @env BATS_LIB_PATH={{BATS_LIB_PATH}} {{BATS}} --jobs $(nproc) test/testlib/**/test/*.test.bats
