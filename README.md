# dev-kit

This repository contains the core infrastructure stack for local development, based on Docker and Traefik. It provides shared services like databases, caching, and a reverse proxy for all your projects.

## Prerequisites

Before you begin, ensure you have the following tools installed on your **host machine**.

### 1. Docker Engine with the Compose command
This stack is managed using the modern `docker compose` command (note the space, not a hyphen).

-   **macOS & Windows:** Install [Docker Desktop](https://www.docker.com/products/docker-desktop/). It includes everything you need: the Docker Engine and the `docker compose` command are available out-of-the-box.

-   **Linux:** Follow the official installation guide for your specific distribution on the Docker website. The recommended installation method now bundles all necessary packages, including the `compose` plugin, into a single command.
    -   **[Find your distribution's guide here: Docker Engine installation guide](https://docs.docker.com/engine/install/)**

    When you follow the official steps, the final installation command will install `docker-ce`, `docker-ce-cli`, `containerd.io`, and `docker-compose-plugin` all at once, ensuring you have the complete, up-to-date toolset.

### 2. Make
A `Makefile` is used to simplify common commands.

-   **macOS:** `make` is pre-installed with Xcode Command Line Tools. Run `xcode-select --install` if you don't have it.
-   **Linux:** Install it via your package manager (e.g., `sudo apt-get install make`).
-   **Windows:** The recommended approach is to use `make` from within your WSL distribution.

### 3. mkcert
`mkcert` is used to create locally-trusted TLS certificates for running HTTPS on local domains.

**Crucial for Windows/WSL users:** `mkcert` must be installed and run **on your Windows host**, not inside the WSL environment, so that your browser trusts the certificates.

-   **macOS:** `brew install mkcert`
-   **Linux:** Follow the [official mkcert installation instructions](https://github.com/FiloSottile/mkcert#installation).
-   **Windows:** Use a package manager like Chocolatey (`choco install mkcert`) or Scoop (`scoop install mkcert`).

#### One-Time Trust Setup
After installing `mkcert`, you must run the following command **once per machine** to install its local Certificate Authority (CA). This makes your system and browsers trust the certificates you generate.

```bash
# On macOS or Linux (in Terminal)
mkcert -install

# On Windows (in PowerShell as Administrator)
mkcert -install
```
You may be prompted for your password or a security confirmation. This is expected.

---

## Getting Started: First-Time Setup

Follow these steps to perform the initial setup of the environment.

### Step 1: Clone the Repository
If you haven't already, clone this repository to your local machine:
```bash
git clone <your-repository-url>
cd dev-kit
```

### Step 2: Generate TLS Certificates
This step needs to be done once per project.

-   **On macOS & Linux:**
    Run the following `make` command:
    ```bash
    make generate-certs
    ```

-   **On Windows:**
    You must run this command manually from **PowerShell** or **CMD** in the project's root directory:
    ```powershell
    mkcert -cert-file docker/traefik/certs/local-cert.pem -key-file docker/traefik/certs/local-key.pem "app.loc" "*.app.loc"
    ```

### Step 3: Initialize and Start the Environment
Now, run the main `init` command. This is a comprehensive script that will:
-   Create your local `.env` file from the example.
-   Ensure Docker networks are present.
-   Pull the latest versions of all Docker images.
-   Build the images.
-   Start all services in the background.

```bash
make init
```
This command might take a few minutes on the first run. Once it's done, your entire development stack is up and running.

---

## Daily Workflow

After the initial setup, you will use these shorter commands for day-to-day work:

-   To **start** all services:
    ```bash
    make up
    ```

-   To **stop** all services:
    ```bash
    make down
    ```

-   To **restart** all services:
    ```bash
    make restart
    ```

---

## Command Reference

Here is a summary of the most useful commands. For a complete list, run `make help`.

| Command             | Description                                                                 |
| ------------------- | --------------------------------------------------------------------------- |
| **Workflow**        |                                                                             |
| `make init`         | **Full reset:** Re-initializes and restarts the entire environment.         |
| `make up`           | Starts all services without rebuilding.                                     |
| `make down`         | Stops all services.                                                         |
| `make restart`      | Restarts all services.                                                      |
| **Maintenance**     |                                                                             |
| `make pull`         | Pulls the latest versions of all Docker images.                             |
| `make build`        | Forces a rebuild of all services.                                           |
| `make generate-certs`| (Linux/macOS only) Generates or regenerates TLS certificates.               |
| `make docker-down-clear` | **DANGER:** Stops services and **deletes all data** (volumes).          |
| **Information**     |                                                                             |
| `make info`         | Displays useful project URLs.                                               |
| `make help`         | Displays the full list of available commands.                               |


## Accessing Services

Key services can be accessed via the following URLs:

-   **Traefik Dashboard:** `https://traefik.app.loc`

You can run `make info` at any time to see a list of important URLs.
