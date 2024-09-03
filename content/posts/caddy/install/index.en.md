---
title: 'Install Caddy on Linux'
description: How to install Caddy on Debian Linux server.
summary: How to install Caddy on Debian Linux server.
date: 2024-08-15
tags: [ "web", "webserver", "HTTP", "caddy"]
keywords: [ "web", "webserver", "HTTP", "caddy"]
draft:  false
thumbnailAlt: "Caddy logo"
coverAlt: "cover-caddy-install-en"
aliases: ["docs/caddy/install"]
---

## Download binary

Download the latest binary in `.tar.gz` archive from GitHub Releases: [https://github.com/caddyserver/caddy/releases/latest](https://github.com/caddyserver/caddy/releases/latest)

```bash
wget "https://github.com/caddyserver/caddy/releases/download/v2.7.6/caddy_2.7.6_linux_amd64.tar.gz"
```

### Verify Checksum

```bash
wget "https://github.com/caddyserver/caddy/releases/download/v2.7.6/caddy_2.7.6_checksums.txt"
```

```bash
sha512sum --ignore-missing -c "caddy_2.7.6_checksums.txt"
```

### Verify Signature

See [Caddy's documentation](https://caddyserver.com/docs/signature-verification) how to verify the signature.

## Extract the binary

Extract the binary from the downloaded archive:

```bash
tar -xf "caddy_2.7.6_linux_amd64.tar.gz caddy"
```

## Install the binary

Use the `install` command to copy the binary to `/usr/local/bin/` and set attributes:

```bash
sudo install -v caddy /usr/bin/
```

## Create user and group

Create the group first:

```bash
sudo groupadd --system caddy
```

Create the `caddy` user:

```bash
sudo useradd --system --gid="caddy" --create-home  --home-dir="/var/lib/caddy" --shell="/usr/sbin/nologin" caddy
```

## Create Caddyfile

Create the directory for the Caddyfile:

```bash
mkdir "/etc/caddy"
```

Now, create the Caddyfile:

```bash
touch "/etc/caddy/Caddyfile"
```

Change the user and group of the config directory:

```bash
chown -R caddy:caddy /etc/caddy/
```

## Configure systemd

Create the systemd service:

```bash
nano /etc/systemd/system/caddy.service
```

```ini title="/etc/systemd/system/caddy.service"
[Unit]
Description=Caddy
After=network.target network-online.target
Requires=network-online.target

[Service]
Type=notify
User=caddy
Group=caddy
ExecStartPre=/usr/bin/caddy validate --config /etc/caddy/Caddyfile
ExecStart=/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile --force
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
sudo systemctl enable --now caddy
```