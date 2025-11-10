# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository provides a Jenkins LTS setup running in Docker with Docker-in-Docker (DinD) capabilities. The architecture allows Jenkins jobs to execute Docker commands using the host's Docker daemon through socket mounting.

## Architecture

The setup consists of three main components:

1. **Dockerfile**: Extends the official `jenkins/jenkins:lts` image and installs Docker CLI, Buildx, and Compose plugins inside the Jenkins container
2. **docker-compose.yml**: Orchestrates the Jenkins service with privileged mode, socket mounting (`/var/run/docker.sock`), and persistent volume management
3. **Socket Mounting Strategy**: The host's Docker daemon is made available to Jenkins by mounting `/var/run/docker.sock`, enabling Jenkins to control Docker without running Docker-in-Docker as a separate daemon

## Common Commands

### Build and Run
```bash
# Build the custom Jenkins image and start the service
docker compose up -d

# Build without cache (when Dockerfile changes)
docker compose build --no-cache
docker compose up -d

# View logs
docker compose logs -f jenkins
```

### Access and Configuration
```bash
# Get initial admin password for first-time setup
docker exec -it <container_name> cat /var/jenkins_home/secrets/initialAdminPassword

# Access Jenkins shell for debugging
docker exec -it <container_name> bash
```

### Stop and Clean Up
```bash
# Stop Jenkins service
docker compose down

# Remove Jenkins data volume (WARNING: deletes all Jenkins configuration and jobs)
docker volume rm docker-jenkins_jenkins_home
```

## Key Configuration Details

- **Ports**: Jenkins UI on `8080`, agent communication on `50000`
- **Privileged Mode**: Required for Docker operations within Jenkins
- **User Context**: Container runs as `root` to access Docker socket
- **Environment Variables**:
  - `DOCKER_HOST=unix:///var/run/docker.sock` - Points to host Docker daemon
  - `DOCKER_BUILDKIT=1` - Enables BuildKit for improved builds

## Security Considerations

The Jenkins container has full access to the host's Docker daemon via socket mounting. This grants complete control over the host system. This setup should only be used in trusted environments, as compromised Jenkins jobs could manipulate host containers and potentially escape containment.

## Access

After starting, Jenkins is accessible at `http://localhost:8080`
