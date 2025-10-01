# Justfile for sops-exec-action
# Default recipe - list all available recipes
default:
    @just --list

# Variables
SHFMT := "shfmt"
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
all: fmt check test

# ---- Format ----

# Format all shell files (via shfmt)
fmt:
    @echo "Formatting shell scripts..."
    {{SHFMT}} --indent 0 --write action.sh
    @echo "Formatting testlib shell scripts..."
    {{SHFMT}} --indent 0 --write test/testlib/**/*.bash
    @echo "Formatting BATS test files..."
    {{SHFMT}} --indent 0 --language-dialect bats --write test/*.bats test/testlib/**/test/*.bats

# Check formatting of all shell files (via shfmt)
fmt-check:
    @echo "Checking shell scripts formatting..."
    {{SHFMT}} --indent 0 --diff action.sh
    @echo "Checking testlib shell scripts formatting..."
    {{SHFMT}} --indent 0 --diff test/testlib/**/*.bash
    @echo "Checking BATS test files formatting..."
    {{SHFMT}} --indent 0 --language-dialect bats --diff test/*.bats test/testlib/**/test/*.bats


# ---- Check ----

# Run all available static checks
check: shellcheck yamllint

# Lint shell scripts (via shellcheck)
shellcheck:
    @echo "Linting shell scripts..."
    @{{SHELLCHECK}} --external-sources --shell=bash action.sh

# Lint YAML files (via yamllint)
yamllint:
    @echo "Linting YAML files..."
    @{{YAMLLINT}} action.yaml

# Lint testlib shell scripts (via shellcheck)
check-testlib:
    @echo "Linting testlib shell scripts..."
    @{{SHELLCHECK}} --external-sources --shell=bash test/testlib/**/*.bash
# ---- Test ----

# Run all tests
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
