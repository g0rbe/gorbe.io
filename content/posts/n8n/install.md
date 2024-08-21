---
sidebar_label: Install
title: "Install n8n"
tags: ["automation", "npm", "selfhost", "homelab"]
description: "Install n8n on Debian Linux."
---

## Requirements

Install [Node.js 18 or above](../nodejs/install.mdx).

## Create user nad group

```bash
groupadd --system n8n
```

```bash
sudo useradd --system --gid n8n --create-home  --home-dir /opt/n8n --shell /usr/sbin/nologin n8n
```

## Install

Install `n8n` globally with `npm`:

```bash
npm install n8n -g
```

## Start automatically

Configure a [systemd service](../systemd/service-unit-configuration.md) to start automatically at boot.

```bash
nano /etc/systemd/system/n8n.service
```

```ini title="/etc/systemd/system/n8n.service"
[Unit]
Description=n8n servce
After=network.target network-online.target
Requires=network-online.target

[Service]
User=n8n
Group=n8n
#WorkingDirectory=
Type=exec
Restart=always
RestartSec=1
ExecStart=/usr/bin/n8n start

[Install]
WantedBy=multi-user.target
```