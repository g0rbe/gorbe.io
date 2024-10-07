---
title: "Install n8n"
description: "Install n8n on Debian Linux."
summary: "Install n8n on Debian Linux."
date: 2024-04-19
tags: ["n8n", "automation", "npm", "selfhost", "homelab"]
keywords: ["n8n", "automation", "npm", "selfhost", "homelab"]
thumbnailAlt: n8n Logo
aliases: ["/docs/n8n/install"]
---

## Requirements

Install [Node.js 18 or above](../nodejs/install.md).

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

Configure a [systemd service](../systemd/service-unit-configuration/index.en.md) to start automatically at boot.

```bash
nano /etc/systemd/system/n8n.service
```

```systemd
[Unit]
Description=n8n servce
After=network.target network-online.target
Requires=network-online.target

[Service]
User=n8n
Group=n8n
Type=exec
Restart=always
RestartSec=1
ExecStart=/usr/bin/n8n start

[Install]
WantedBy=multi-user.target
```