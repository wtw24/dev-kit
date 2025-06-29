.DEFAULT_GOAL := help

# --- Configuration ---
UID := $(shell id -u)
GID := $(shell id -g)

CERT_DIR := docker/traefik/certs
CERT_FILE := $(CERT_DIR)/local-cert.pem
KEY_FILE := $(CERT_DIR)/local-key.pem

# --- Colors ---
COLOR_GREEN  := \033[1;32m
COLOR_YELLOW := \033[1;33m
COLOR_RED    := \033[1;31m
COLOR_DEFAULT:= \033[0m

# Объявляем все цели, чтобы make не искал одноименные файлы
.PHONY: init up down restart docker-down-clear \
        pull build generate-certs check-certs info \
        pre-scripts post-scripts docker-up docker-down success \
        create-env-file create-networks help

# ====================================================================================
#  Workflow Commands
# ====================================================================================

init: pre-scripts docker-down docker-pull docker-build docker-up post-scripts ## Full reset: Re-initializes and restarts the entire environment.
up: docker-up post-scripts ## Starts the environment without rebuilding.
down: docker-down ## Stops the environment.
restart: down up ## Restarts the environment.

# ====================================================================================
#  Advanced Docker Commands
# ====================================================================================

docker-down-clear: ## DANGER: Stops and removes all volumes (deletes all data).
	@echo ""
	@echo "$(COLOR_RED)🔥 WARNING: You are about to permanently delete ALL Docker volumes for this project.$(COLOR_DEFAULT)"
	@echo "$(COLOR_RED)   This includes all databases, cached data, etc. This action CANNOT be undone.$(COLOR_DEFAULT)"
	@echo ""
	@read -p "Type 'YES' in all caps to confirm: " CONFIRM; \
	if [ "$$CONFIRM" = "YES" ]; then \
		echo ""; \
		echo "Confirmation received. Proceeding with data deletion..."; \
		docker compose down -v --remove-orphans; \
		echo "$(COLOR_GREEN)✓ All services and associated volumes have been successfully removed.$(COLOR_DEFAULT)"; \
	else \
		echo ""; \
		echo "Confirmation not received. Operation cancelled."; \
	fi

pull: docker-pull ## Pulls the latest versions of all Docker images.
build: docker-build ## Forces a rebuild of all Docker images.

# ====================================================================================
#  Internal Steps & Scripts
# ====================================================================================

# -- Script Groups --
pre-scripts: create-env-file create-networks check-certs
post-scripts: success info

# -- Docker Wrappers --
docker-up:
	@echo "✓ Starting containers..."
	@docker compose up -d

docker-down:
	@echo "✓ Stopping containers..."
	@docker compose down --remove-orphans

docker-pull:
	@echo "✓ Pulling latest images..."
	@docker compose pull

docker-build:
	@echo "✓ Building services..."
	@docker compose build --pull

# -- Setup Scripts --
create-env-file:
	@echo "✓ Ensuring .env file exists..."
	@docker run --rm -it -v ${PWD}:/app -w /app -u ${UID}:${GID} bash:5.2 bash docker/bin/create-env-file.sh

create-networks:
	@echo "✓ Ensuring Docker networks exist..."
	@docker network create proxy 2>/dev/null || true
	@docker network create dev 2>/dev/null || true

check-certs: $(CERT_FILE)
	@echo "✓ Certificates are in place."

$(CERT_FILE):
	@echo "$(COLOR_RED)-✓ ERROR: Certificate file not found at [$(CERT_FILE)]$(COLOR_DEFAULT)"
	@echo "$(COLOR_YELLOW)If on macOS/Linux, run 'make generate-certs' to create them.$(COLOR_DEFAULT)"
	@echo "$(COLOR_YELLOW)If on Windows/WSL, follow README.md to generate certs from PowerShell.$(COLOR_DEFAULT)"
	@exit 1

generate-certs: ## (Linux/macOS only) Generates or regenerates TLS certificates.
	@if [ -f "$(CERT_FILE)" ]; then \
    		echo "$(COLOR_YELLOW)✓ Regenerating existing certificates...$(COLOR_DEFAULT)"; \
    	else \
    		echo "$(COLOR_YELLOW)✓ Generating new certificates...$(COLOR_DEFAULT)"; \
    	fi
	@echo "   IMPORTANT: Make sure you have run 'mkcert -install' once on your machine."
	@mkdir -p $(CERT_DIR)
	@mkcert -cert-file $(CERT_FILE) -key-file $(KEY_FILE) "app.loc" "*.app.loc"
	@echo "$(COLOR_GREEN)✓ Certificates successfully created/updated.$(COLOR_DEFAULT)"

# -- Finalization --
success:
	@echo "\n$(COLOR_GREEN)✓ Environment is up and running.$(COLOR_DEFAULT)"

info: ## Displays useful project URLs.
	@echo "\nAccessing Services:"
	@echo " - Traefik: \t\t https://traefik.app.loc"
	@echo " - Buggregator: \t https://buggregator.app.loc"
	@echo " - Dozzle: \t\t https://logs.app.loc"
	@echo " "


help: ## Displays this help message.
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'