---
title: Install FrankenPHP on Linux
description: How to install FrankenPHP on Debian Linux server.
summary: How to install FrankenPHP on Debian Linux server.
date: 2024-08-21
tags: [ "web", "webserver", "HTTP", "php", "cgi"]
keywords: [ "web", "webserver", "HTTP", "php", "cgi"]
draft:  false
aliases: ["/docs/frankenphp/install"]
---

## TL;DR

```bash
wget -q -O- 'https://gorbe.io/assets/docs/frankenphp/install/frankenphp-install.sh' | bash -x -
```

## Download binary

Download the latest binary from GitHub Releases: [https://github.com/dunglas/frankenphp/releases](https://github.com/dunglas/frankenphp/releases)

```bash
wget "https://github.com/dunglas/frankenphp/releases/download/v1.1.4/frankenphp-linux-$(uname -m)"
```

## Install the binary

Use the `install` command to copy the binary to `/usr/bin/` and set attributes:

```bash
sudo install -v "frankenphp-linux-$(uname -m)" /usr/bin/frankenphp
```

## Create user and group

Create the group first:

```bash
sudo groupadd --system frankenphp
```

Create the `frankenphp` user:

```bash
sudo useradd --system --gid frankenphp --create-home  --home-dir /var/lib/frankenphp --shell /usr/sbin/nologin frankenphp
```

## Create Caddyfile

Create the directory for the Caddyfile:

```bash
mkdir /etc/frankenphp
```

Now, create the Caddyfile:

```bash
echo -e "{\n}" > /etc/frankenphp/Caddyfile
```

Change the user and group of the config directory:

```bash
chown -R frankenphp:frankenphp /etc/frankenphp/
```

## Configure systemd

Create the systemd service:

```bash
nano /etc/systemd/system/frankenphp.service
```

```systemd title="/etc/systemd/system/frankenphp.service"
[Unit]
Description=FrankenPHP Server
After=network.target network-online.target
Requires=network-online.target

[Service]
Type=notify
User=frankenphp
Group=frankenphp
ExecStartPre=/usr/bin/frankenphp validate --config /etc/frankenphp/Caddyfile
ExecStart=/usr/bin/frankenphp run --environ --config /etc/frankenphp/Caddyfile
ExecReload=/usr/bin/frankenphp reload --config /etc/frankenphp/Caddyfile --force
TimeoutStopSec=5s
LimitNOFILE=1048576
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
```

Reload systemd to load the new service:

```bash
sudo systemctl daemon-reload
```

Enable the service to start at boot:

```bash
sudo systemctl enable --now frankenphp
```