ifneq (, $(shell which tput))
	GREEN  := $(shell tput -Txterm setaf 2)
	YELLOW := $(shell tput -Txterm setaf 3)
	WHITE  := $(shell tput -Txterm setaf 7)
	CYAN   := $(shell tput -Txterm setaf 6)
	RESET  := $(shell tput -Txterm sgr0)
endif

# Variables ######################################################################################
# Tools
SHELLCHECK=shellcheck
YAMLLINT=yamllint
BATS=bats

# Targets ########################################################################################
.PHONY: all lint shellcheck yamllint test unittest inttest help
.DEFAULT_GOAL := all

all: 	## Run all available checks and tests
all: check test


## Check:
check:		## Run all available static checks
check: shellcheck yamllint

shellcheck:	## Lint shell scripts (via shellcheck)
	@echo "Linting shell scripts..."
	@$(SHELLCHECK) -x -s bash action.sh

yamllint:	## Lint YAML files (via yamllint)
	@echo "Linting YAML files..."
	@$(YAMLLINT) action.yaml

## Test:
test:	## Run all available tests
test: unittest inttest

# Create symlinks to test libraries
setup-testlibs:
ifeq ($(CI),true)
	@echo "Skipping setup as CI environment variable is not set."
else
	@echo "Setting up test environment..."
	@if [ ! -e test/libs/bats-support ]; then ln -sf /usr/lib/bats/bats-support test/libs/bats-support; fi
	@if [ ! -e test/libs/bats-assert ]; then ln -sf /usr/lib/bats/bats-assert test/libs/bats-assert; fi
	@if [ ! -e test/libs/bats-file ]; then ln -sf /usr/lib/bats/bats-file test/libs/bats-file; fi
endif


unittest: setup-testlibs	## Run unit tests
	@echo "Running unit tests..."
	@$(BATS) test/*.test.sh

inttest:		## Run integration tests
	@echo "Running integration tests..."
	@echo "No integration tests available."


## Help:
help:		## Show this help
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)
