# Dev-Kit

This repository contains the core infrastructure stack for local development, based on Docker and Traefik. It provides shared services like databases, caching, and a reverse proxy for all your projects.

## Prerequisites

Before you begin, ensure you have the following tools installed on your **host machine**.

### 1. Docker Engine with the Compose command
This stack is managed using the modern `docker compose` command.

-   **macOS & Windows:** Install [Docker Desktop](https://www.docker.com/products/docker-desktop/). It includes everything you need.
-   **Linux:** Follow the official [Docker Engine installation guide](https://docs.docker.com/engine/install/) for your distribution. The recommended method now bundles all necessary packages, including the `compose` plugin.

### 2. Make
A `Makefile` is used to simplify common commands.

-   **macOS:** Pre-installed with Xcode Command Line Tools (`xcode-select --install`).
-   **Linux:** Install via your package manager (e.g., `sudo apt-get install make`).
-   **Windows:** Use `make` from within your WSL distribution.

### 3. mkcert
`mkcert` is used to create locally-trusted TLS certificates.

-   **Installation:** Follow the installation guide for your OS on the [official mkcert page](https://github.com/FiloSottile/mkcert#installation).
-   **One-Time Trust Setup:** After installing, run `mkcert -install` **once per machine** to make your system trust the certificates. On Windows, this must be done in PowerShell (as Administrator).

---

## Getting Started: First-Time Setup

Follow these steps to perform the initial setup of the environment.

### Step 1: Configure Your Hosts File
For your browser to access local domains like `traefik.app.loc`, you must tell your operating system to resolve them to your local machine (`127.0.0.1`). This requires editing the `hosts` file with administrator privileges.

**Add the following line to your hosts file:**
```
127.0.0.1 traefik.app.loc
127.0.0.1 buggregator.app.loc
```
*(Note: As you add new projects, you will need to add their subdomains here as well, e.g., `my-project.app.loc`)*

-   **On macOS & Linux:**
    1.  Open a terminal.
    2.  Run `sudo nano /etc/hosts`.
    3.  Enter your password.
    4.  Add the line, then save the file by pressing `Ctrl+X`, then `Y`, then `Enter`.

-   **On Windows:**
    1.  Press the Windows key, type "Notepad".
    2.  Right-click on the Notepad icon and select **"Run as administrator"**.
    3.  In Notepad, go to `File > Open`.
    4.  Navigate to `C:\Windows\System32\drivers\etc`.
    5.  Change the file type filter in the bottom-right from "Text Documents (*.txt)" to **"All Files (*.*)"**.
    6.  Select the `hosts` file and click "Open".
    7.  Add the line at the end of the file and save.

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
Now, run the main `init` command. This will prepare and start the entire stack.

```bash
make init
```
This command might take a few minutes on the first run. Once it's done, your entire development stack is up and running.

---

## Daily Workflow

After the initial setup, you will use these shorter commands for day-to-day work:

-   To **start** all services: `make up`
-   To **stop** all services: `make down`
-   To **restart** all services: `make restart`

---

## Command Reference

This project uses a `Makefile` to provide shortcuts. Run `make help` for a complete list. Here are the most common commands:

| Command             | Description                                                                 |
| ------------------- | --------------------------------------------------------------------------- |
| `make init`         | **Full reset:** Re-initializes and restarts the entire environment.         |
| `make up`           | Starts all services without rebuilding.                                     |
| `make down`         | Stops all services.                                                         |
| `make restart`      | Restarts all services.                                                      |
| `make generate-certs`| (Linux/macOS only) Generates or regenerates TLS certificates.               |
| `make info`         | Displays useful project URLs.                                               |

---

## Accessing Services

Key services can be accessed via the following URLs (after completing the setup):

-   **Traefik Dashboard:** `https://traefik.app.loc`
-   **Buggregator:** `https://buggregator.app.loc`
-   **Dozzle:** `https://logs.app.loc`

Run `make info` at any time to see a list of important URLs.


## Used Images

- https://hub.docker.com/_/traefik
- https://github.com/buggregator/server/pkgs/container/server
- https://hub.docker.com/r/amir20/dozzle