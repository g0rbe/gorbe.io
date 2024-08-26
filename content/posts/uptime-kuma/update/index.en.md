---
title: "Update Uptime Kuma from Source"
description: "Update Uptime Kuma from Source with Nginx on Debian 12"
date: 2024-01-30T17:46:33+01:00
tags: ["monitor", "monitoring", "selfhosted", "self-hosted", "uptime", "uptime-monitoring", "Uptime Kuma"]
keywords: ["monitor", "monitoring", "selfhosted", "self-hosted", "uptime", "uptime-monitoring", "Uptime Kuma"]
aliases: ["/docs/uptime-kuma/update-from-source"]
---

```bash
cd <uptime-kuma-directory>
```

## Update from git

```bash
git fetch --all
```

```bash
git checkout $(curl -s 'https://api.github.com/repos/louislam/uptime-kuma/releases/latest' | jq -r '.tag_name') --force
```

## Install dependencies and prebuilt

```bash
npm install --production
```

```bash
npm run download-dist
```

## Restart

```bash
systemctl restart uptime-kuma
```
