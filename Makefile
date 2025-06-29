.DEFAULT_GOAL := help

# --- Configuration ---
UID=$(shell id -u)
GID=$(shell id -g)

CERT_FILE := docker/traefik/certs/local-cert.pem

# --- Colors ---
COLOR_GREEN=\033[1;32m
COLOR_YELLOW=\033[1;33m
COLOR_DEFAULT=\033[0m

.PHONY: init create-env-file success help

# --- Main Commands ---
init: pre-scripts post-scripts ## Initializes the project environment (creates .env file)

pre-scripts: create-env-file create-networks
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
	@echo "$(R)--> ERROR: Certificate file not found at [$(CERT_FILE)]$(EC)"
	@echo "$(Y)If you are on macOS/Linux, run 'make generate-certs' to create them.$(EC)"
	@echo "$(Y)If you are on Windows/WSL, please follow the setup instructions in README.md to generate certs from PowerShell/CMD.$(EC)"
	@exit 1

check-certs: $(CERT_FILE) ## Checks if TLS certificates exist.
	@echo "-> Certificates are in place."

generate-certs: ## (Linux/macOS only) Generates or regenerates TLS certificates.
	@if [ -f "$(CERT_FILE)" ]; then \
    		echo "$(COLOR_YELLOW)-> Regenerating existing certificates...$(COLOR_DEFAULT)"; \
    	else \
    		echo "$(COLOR_YELLOW)-> Generating new certificates...$(COLOR_DEFAULT)"; \
    	fi
	@echo "   IMPORTANT: Make sure you have run 'mkcert -install' once on your machine."
	@mkdir -p $(CERT_DIR)
	@mkcert -cert-file $(CERT_FILE) -key-file $(KEY_FILE) "app.loc" "*.app.loc"
	@echo "$(COLOR_GREEN)✓ Certificates successfully created/updated.$(COLOR_DEFAULT)"

success:
	@echo "\n$(COLOR_GREEN)✓ Environment has been successfully initialized.$(COLOR_DEFAULT)"

help: ## Displays this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'