# --- Configuration ---
# Pass current user's UID/GID to Docker Compose to avoid permission issues
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

# --- Main Settings ---
.DEFAULT_GOAL := help

.PHONY: init up down restart docker-down-clear \
        pull build generate-certs check-certs info \
        pre-scripts post-scripts docker-up docker-down success \
        create-env-file create-networks help


# ====================================================================================
#  Workflow Commands
# ====================================================================================

## Full reset: Re-initializes and restarts the entire environment.
init: pre-scripts docker-down docker-pull docker-build docker-up post-scripts

## Starts the environment without rebuilding.
up: docker-up post-scripts

## Stops the environment.
down: docker-down

## Restarts the environment.
restart: down up


# ====================================================================================
#  Advanced Docker Commands
# ====================================================================================

## DANGER: Stops and removes all volumes (deletes all data).
docker-down-clear:
	@printf "\n%b   WARNING: You are about to permanently delete ALL Docker volumes for this project.%b\n" "$(COLOR_RED)" "$(COLOR_DEFAULT)"
	@printf "%b   This includes all databases, cached data, etc. This action CANNOT be undone.%b\n\n" "$(COLOR_RED)" "$(COLOR_DEFAULT)"
	@read -p "Type 'YES' in all caps to confirm: " CONFIRM; \
	if [ "$$CONFIRM" = "YES" ]; then \
		@printf "\nConfirmation received. Proceeding with data deletion...\n"; \
		@docker compose down -v --remove-orphans; \
		@printf "✓%b All services and associated volumes have been successfully removed.%b\n" "$(COLOR_GREEN)" "$(COLOR_DEFAULT)"; \
	else \
		@printf "\nConfirmation not received. Operation cancelled.\n"; \
	fi


# ====================================================================================
#  Internal Steps & Scripts
# ====================================================================================

# -- Script Groups --
pre-scripts: create-env-file create-networks check-certs
post-scripts: success info

# -- Docker Wrappers --
docker-up:
	@printf "✓ Starting containers...\n"
	@docker compose up -d

docker-down:
	@printf "✓ Stopping containers...\n"
	@docker compose down --remove-orphans

docker-pull:
	@printf "✓ Pulling latest images...\n"
	@docker compose pull

docker-build:
	@printf "✓ Building services...\n"
	@docker compose build --pull

# -- Setup Scripts --
create-env-file:
	@printf "✓ Ensuring .env file exists...\n"
	@docker run --rm -it -v ${PWD}:/app -w /app -u ${UID}:${GID} bash:5.2 bash docker/bin/create-env-file.sh

create-networks:
	@printf "✓ Ensuring Docker networks exist...\n"
	@docker network create proxy 2>/dev/null || true
	@docker network create dev 2>/dev/null || true

check-certs: $(CERT_FILE)
	@printf "✓ Certificates are in place.\n"

$(CERT_FILE):
	@printf "-%b ERROR: Certificate file not found at [%s]%b\n" "$(COLOR_RED)" "$(CERT_FILE)" "$(COLOR_DEFAULT)"
	@printf "%bIf on macOS/Linux, run 'make generate-certs' to create them.%b\n" "$(COLOR_YELLOW)" "$(COLOR_DEFAULT)"
	@printf "%bIf on Windows/WSL, follow README.md to generate certs from PowerShell.%b\n" "$(COLOR_YELLOW)" "$(COLOR_DEFAULT)"
	@exit 1

## (Linux/macOS only) Generates or regenerates TLS certificates.
generate-certs:
	@if [ -f "$(CERT_FILE)" ]; then \
		@printf "✓%b Regenerating existing certificates...%b\n" "$(COLOR_YELLOW)" "$(COLOR_DEFAULT)"; \
	else \
		@printf "✓%b Generating new certificates...%b\n" "$(COLOR_YELLOW)" "$(COLOR_DEFAULT)"; \
	fi
	@printf "   IMPORTANT: Make sure you have run 'mkcert -install' once on your machine.\n"
	@mkdir -p $(CERT_DIR)
	@mkcert -cert-file $(CERT_FILE) -key-file $(KEY_FILE) "app.loc" "*.app.loc"
	@printf "%b✓ Certificates successfully created/updated.%b\n" "$(COLOR_GREEN)" "$(COLOR_DEFAULT)"

# -- Finalization --
success:
	@printf "\n✓%b Environment is up and running.%b\n\n" "$(COLOR_GREEN)" "$(COLOR_DEFAULT)"

## Displays useful project URLs.
info:
	@printf "\n%bAccessing Services:%b\n" "$(COLOR_YELLOW)" "$(COLOR_DEFAULT)"
	@printf " - Traefik:      https://traefik.app.loc\n"
	@printf " - Buggregator:  https://buggregator.app.loc\n"
	@printf " - Dozzle:       https://logs.app.loc\n\n"


## Displays this help message.
help:
	@printf "Usage: make [target]\n\n"
	@printf "Available targets:\n"
	@awk ' \
		/^##/{ \
			h=substr($$0, 4); \
			next \
		} \
		{ \
			if (h != "" && $$0 ~ /^[a-zA-Z0-9_-]+:/) { \
				split($$0, t, ":"); \
				printf "  \033[36m%-18s\033[0m %s\n", t[1], h; \
			} \
			h="" \
		} \
	' $(MAKEFILE_LIST) | sort