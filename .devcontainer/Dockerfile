FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install prerequisites
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    curl \
    wget \
    unzip \
    jq \
    ca-certificates \
    iputils-ping \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install Terraform (version 1.14.0 or later)
ARG TERRAFORM_VERSION=1.14.0
RUN wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -O /tmp/terraform.zip \
    && unzip -q /tmp/terraform.zip -d /tmp \
    && mv /tmp/terraform /usr/local/bin/terraform \
    && chmod +x /usr/local/bin/terraform \
    && rm /tmp/terraform.zip

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/aws /tmp/awscliv2.zip

# Verify installations
RUN terraform version && aws --version

# Set up SSH directory with proper permissions
RUN mkdir -p /home/vscode/.ssh \
    && chmod 700 /home/vscode/.ssh \
    && chown -R vscode:vscode /home/vscode/.ssh

