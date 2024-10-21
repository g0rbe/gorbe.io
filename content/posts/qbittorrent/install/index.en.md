---
title: Install qBittorrent Server
description: Install qBittorrent Server on Linux
summary: Install qBittorrent Server on Linux
date: 2024-10-21T17:33:34+02:00
tags: ["qBittorrent", "torrent"]
keywords: ["qBittorrent", "torrent"]
# featureAlt:
thumbnailAlt: qBittorrent Logo
coverAlt:  Install qBittorrent Server Cover
# draft:  true
# aliases: ['/']
---

## Requirements

```bash
apt install gpg
```

## Configure APT repository

```bash
echo 'deb http://download.opensuse.org/repositories/home:/nikoneko:/test/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/qbittorrent.list
```

```bash
wget -O- "https://download.opensuse.org/repositories/home:nikoneko:test/Debian_12/Release.key" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/qbittorrent.gpg > /dev/null
```

```bash
sudo apt update
```

```bash
sudo apt install qbittorrent-nox
```

## Create user and group

Create the group first:

```bash
sudo groupadd --system qbittorrent
```

Create the `qbittorrent` user:

```bash
sudo useradd --system --gid="qbittorrent" --create-home  --home-dir="/var/lib/qbittorrent" --shell="/usr/sbin/nologin" qbittorrent
```

## Configure systemd

Create the systemd service:

```bash
nano /etc/systemd/system/qbittorrent.service
```

```ini
[Unit]
Description=qBittorrent
After=network.target network-online.target
Requires=network-online.target

[Service]
Type=simple
User=qbittorrent
Group=qbittorrent
ExecStart=/usr/bin/qbittorrent-nox

[Install]
WantedBy=multi-user.target
```

Reload systemd to load the new service:

```bash
sudo systemctl daemon-reload
```

Enable the service to start at boot:

```bash
sudo systemctl enable --now qbittorrent
```

## Config

The configuration files can be found at:

```bash
/var/lib/qbittorrent/.config/qBittorrent/
```

### Default login

The default login credentials are logged to `journald`:

```bash
journalctl -eu qbittorrent
```