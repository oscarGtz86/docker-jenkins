FROM jenkins/jenkins:lts

USER root

# Install Docker in Jenkins container
RUN apt-get remove -y docker docker-engine docker.io containerd runc docker-ce-cli || true

# Install dependencies for Docker installation
RUN apt-get update && \
    apt-get install -y ca-certificates curl python3 && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker's official APT repository
RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update

# Install Docker packages
RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

USER jenkins
