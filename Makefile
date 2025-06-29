.DEFAULT_GOAL := help

# --- Configuration ---
UID=$(shell id -u)
GID=$(shell id -g)

CERT_DIR := docker/traefik/certs
CERT_FILE := $(CERT_DIR)/local-cert.pem
KEY_FILE := $(CERT_DIR)/local-key.pem

# --- Colors ---
COLOR_GREEN=\033[1;32m
COLOR_YELLOW=\033[1;33m
COLOR_DEFAULT=\033[0m

.PHONY: init create-env-file success help

# --- Main Commands ---
init: pre-scripts post-scripts ## Initializes the project environment (creates .env file)

pre-scripts: create-env-file create-networks certs
post-scripts: success

# --- Internal Steps ---
create-env-file:
	@echo "-> Creating .env file..."
	@docker run --rm -it -v ${PWD}:/app -w /app -u ${UID}:${GID} bash:5.2 bash docker/bin/create-env-file.sh

create-networks:
	@echo "-> Ensuring Docker networks exist..."
	@docker network create dev 2>/dev/null || true
	@docker network create proxy 2>/dev/null || true

$(CERT_FILE):
	@echo "-> Certificates not found. Generating new ones..."
	@echo "   IMPORTANT: Make sure you have run 'mkcert -install' once on your machine."
	@mkdir -p $(CERT_DIR)
	@mkcert -cert-file $(CERT_FILE) -key-file $(KEY_FILE) "app.loc" "*.app.loc"

certs: $(CERT_FILE) ## Generates local TLS certificates if they don't exist.
	@echo "-> Certificates are up to date."

success:
	@echo "\n$(COLOR_GREEN)✓ Environment has been successfully initialized.$(COLOR_DEFAULT)"

help: ## Displays this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'