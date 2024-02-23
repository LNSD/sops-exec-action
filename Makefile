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

# Set the BATS_LIB_PATH environment variable to where the Bats libraries are installed:
#  - Locally: '/usr/lib/bats`
#  - In GHA when using `bats-core/bats-action`: '/usr/lib'
#
# It should also include the testlib directory.
BATS_LIB_PATH=/usr/lib/bats:/usr/lib:$(CURDIR)/test/testlib

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

check-testlib:	## Lint testlib shell scripts (via shellcheck)
	@echo "Linting testlib shell scripts..."
	@$(SHELLCHECK) -x -s bash test/testlib/**/*.bash

## Test:
test:	## Run all available tests
test: unittest inttest

unittest:	## Run unit tests
	@echo "Running unit tests..."
	@env BATS_LIB_PATH=$(BATS_LIB_PATH) $(BATS) test/*.test.sh

inttest:	## Run integration tests
	@echo "Running integration tests..."
	@echo "No integration tests available."

test-testlib:	## Run testlib tests
	@echo "Running testlib tests..."
	@env BATS_LIB_PATH=$(BATS_LIB_PATH) $(BATS) test/testlib/**/test/*.test.sh


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
