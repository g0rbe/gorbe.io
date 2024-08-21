---
sidebar_label: "Install"
title: "Install Docker Engine on Debian 12"
description: "Short guide about how install Docker Engine on Debian 12."
---

Docker has become an essential tool in the world of modern software development. If you're using Debian 12 and want to take advantage of Docker's capabilities, this guide will walk you through the installation process.

---

## Update System Packages

Begin by updating your system’s package index:

```bash
sudo apt update
```
```bash
sudo apt install -y ca-certificates curl gnupg
```

This ensures that you have the necessary packages to securely install Docker.

## Add Docker’s Official GPG Key

Docker’s GPG key ensures the authenticity of the software packages. Add it with:

```bash
sudo install -m 0755 -d /etc/apt/keyrings
```

```bash
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```
```bash
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

Then, add the Docker repository to your system:

```bash
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

This ensures you get the latest version of Docker.

## Install Docker Engine

Now, install the Docker Engine, CLI, and other necessary components:

```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

After installation, the Docker service starts automatically.

## Verify the Installation

To verify Docker is installed correctly, run a test image:

```bash
sudo docker run hello-world
```

If everything is set up correctly, this command will pull a test image and run a container that prints an informational message.

## Enable Docker Command for Non-root Users

By default, running Docker commands requires root privileges. To allow a non-root user to execute Docker commands, add them to the `docker` group:

```bash
sudo usermod -aG docker $USER
newgrp docker
```
