# Jenkins in Docker with Docker-in-Docker Support

This project provides a ready-to-use Jenkins setup running in Docker, with full Docker-in-Docker (DinD) capabilities. It allows Jenkins jobs to build and run Docker containers using the host's Docker daemon.

## Features
- Jenkins LTS running as a Docker container
- Docker CLI and Buildx pre-installed in the Jenkins image
- Access to the host's Docker daemon via volume mount
- Persistent Jenkins data using Docker volumes

## Prerequisites
- [Docker](https://docs.docker.com/get-docker/) installed on your host machine
- [Docker Compose](https://docs.docker.com/compose/install/) (v2 recommended)

## Usage

1. **Clone this repository:**
   ```bash
   git clone https://github.com/oscarGtz86/docker-jenkins.git
   cd docker-jenkins
   ```

2. **Build and start Jenkins:**
   ```bash
   docker compose up -d
   ```

3. **Access Jenkins:**
   - Open your browser and go to [http://localhost:8080](http://localhost:8080)
   - The first time you access Jenkins, you'll be asked for an initial admin password. Find it with:
     ```bash
     docker exec -it <container_id_or_name> cat /var/jenkins_home/secrets/initialAdminPassword
     ```

4. **Install recommended plugins and set up your admin user.**

## How It Works
- The `Dockerfile` extends the official Jenkins LTS image, installs Docker CLI and Buildx, and ensures Jenkins can access Docker.
- The `docker-compose.yml` mounts the host's Docker socket (`/var/run/docker.sock`) into the Jenkins container, enabling Jenkins jobs to run Docker commands.
- Jenkins data is persisted in a Docker volume (`jenkins_home`).

## Security Note
Running Jenkins with access to the host Docker socket grants full control over the host. Use only in trusted environments.

## Stopping Jenkins
```bash
docker compose down
```

## Backup and Restore

### Backup Jenkins Data
Create a backup of all Jenkins data including credentials, pipelines, jobs, and configuration:

```bash
# Create a backup directory
mkdir -p ./jenkins-backups

# Backup the entire Jenkins volume to a tar archive
docker run --rm \
  -v docker-jenkins_jenkins_home:/var/jenkins_home \
  -v $(pwd)/jenkins-backups:/backup \
  alpine tar czf /backup/jenkins-backup-$(date +%Y%m%d-%H%M%S).tar.gz -C /var/jenkins_home .
```

This creates a timestamped backup file in the `jenkins-backups` directory.

### Restore from Backup

```bash
# Stop Jenkins
docker compose down

# Remove old volume (WARNING: This deletes current data)
docker volume rm docker-jenkins_jenkins_home

# Create new volume
docker volume create docker-jenkins_jenkins_home

# Restore from backup (replace YYYYMMDD-HHMMSS with your backup timestamp)
docker run --rm \
  -v docker-jenkins_jenkins_home:/var/jenkins_home \
  -v $(pwd)/jenkins-backups:/backup \
  alpine tar xzf /backup/jenkins-backup-YYYYMMDD-HHMMSS.tar.gz -C /var/jenkins_home

# Start Jenkins
docker compose up -d
```

## Cleaning Up
To remove all Jenkins data:
```bash
docker volume rm docker-jenkins_jenkins_home
```

## References
- [Jenkins Docker Documentation](https://www.jenkins.io/doc/book/installing/docker/)
- [Docker-in-Docker Best Practices](https://docs.docker.com/engine/security/protect-access/)

## Author
Oscar Gutierrez Escamilla