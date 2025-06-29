.DEFAULT_GOAL := help

# --- Configuration ---
UID=$(shell id -u)
GID=$(shell id -g)

# --- Colors ---
COLOR_GREEN=\033[1;32m
COLOR_YELLOW=\033[1;33m
COLOR_DEFAULT=\033[0m

.PHONY: init create-env-file success help

# --- Main Commands ---
init: pre-scripts post-scripts ## Initializes the project environment (creates .env file)

pre-scripts: create-env-file
post-scripts: success

# --- Internal Steps ---
create-env-file:
	@docker run --rm -it -v ${PWD}:/app -w /app -u ${UID}:${GID} bash:5.2 bash docker/bin/create-env-file.sh

success:
	@echo "\n$(COLOR_GREEN)✓ Environment has been successfully initialized.$(COLOR_DEFAULT)"

help: ## Displays this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'