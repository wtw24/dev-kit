# dev-kit

This repository contains the core infrastructure stack for local development, based on Docker and Traefik. It provides shared services like databases, caching, and a reverse proxy for all your projects.

## Quick Start

### 1. Initialization

Before you start, you need to create a local `.env` configuration file. This can be done automatically by running the following command:

```bash
make init
```

This command will:
1.  Check if an `.env` file already exists.
2.  If it doesn't exist, it will copy the `.env.example` template to a new `.env` file.
3.  If `.env` already exists, it will compare it with the `.env.example` template.
4.  If the files are different, it will ask for your confirmation before overwriting your existing `.env` file with the latest template.

You can now review and customize the variables in the newly created `.env` file.

#### Forcing an Overwrite

In automated environments (like CI/CD scripts), you might want to skip the interactive confirmation. To do this, add the following line to your `.env` file:

```dotenv
SKIP_ENV_OVERWRITE_CHECK=true
```

When this variable is set, `make init` will not ask for confirmation if the files differ; it will simply proceed without overwriting. *(Note: This behavior depends on the script logic; the default is to overwrite if confirmation is skipped)*.