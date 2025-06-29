# dev-kit

This repository contains the core infrastructure stack for local development, based on Docker and Traefik. It provides shared services like databases, caching, and a reverse proxy for all your projects.

## Prerequisites

Before you begin, ensure you have the following tools installed on your **host machine**.

### 1. Docker and Docker Compose
This stack relies on Docker to manage all services. Docker Compose is used to orchestrate the containers.

-   **macOS & Windows:** Install [Docker Desktop](https://www.docker.com/products/docker-desktop/). It includes both Docker and Docker Compose.
-   **Linux:** Follow the official instructions to install the [Docker Engine](https://docs.docker.com/engine/install/) and the [Docker Compose plugin](https://docs.docker.com/compose/install/).

### 2. Make
A `Makefile` is used to simplify common commands.

-   **macOS:** `make` is pre-installed with Xcode Command Line Tools. Run `xcode-select --install` if you don't have it.
-   **Linux:** Install it via your package manager (e.g., `sudo apt-get install make` or `sudo dnf install make`).
-   **Windows:** You can use `make` from within WSL.

### 3. mkcert
`mkcert` is used to create locally-trusted TLS certificates for running HTTPS on your local domains.

**Crucial for Windows/WSL users:** `mkcert` must be installed and run **on the machine where your browser is running** (i.e., your Windows host, not inside the WSL environment).

-   **macOS:** `brew install mkcert`
-   **Linux:** Follow the [official mkcert installation instructions](https://github.com/FiloSottile/mkcert#installation).
-   **Windows:** Use a package manager like Chocolatey (`choco install mkcert`) or Scoop (`scoop install mkcert`).

#### One-Time Trust Setup (All Operating Systems)
After installing `mkcert`, you must run the following command **once per machine** to install the local Certificate Authority (CA). This makes your system and browsers trust the certificates you generate.

```bash
# On macOS or Linux (in Terminal)
mkcert -install

# On Windows (in PowerShell as Administrator)
mkcert -install
```
You may be prompted for your password or a security confirmation. This is expected.

## Usage

Follow these steps to get the development environment up and running.

### Step 1: Generate TLS Certificates
First, you need to generate the SSL certificates for your local domain (`app.loc`).

-   **On macOS & Linux:**
    Run the following command. It will create the certificates only if they don't already exist.
    ```bash
    make generate-certs
    ```

-   **On Windows:**
    You must perform this step manually from **PowerShell** or **CMD** in the project's root directory.
    ```powershell
    # Ensure you are in the project's root directory
    mkcert -cert-file docker/traefik/certs/local-cert.pem -key-file docker/traefik/certs/local-key.pem "app.loc" "*.app.loc"
    ```

### Step 2: Initialize the Environment
This command creates the necessary Docker networks and your local `.env` file from the `env.example` template.

```bash
make init
```
After running this, you can review and customize the variables in the newly created `.env` file.

## Available Commands

This project uses a `Makefile` to provide shortcuts for common operations. Run `make help` to see a full list of available commands and their descriptions.