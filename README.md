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