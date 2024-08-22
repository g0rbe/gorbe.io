---
title: "Update Uptime Kuma from Source"
description: "Update Uptime Kuma from Source with Nginx on Debian 12"
tags: ["monitor", "monitoring", "selfhosted", "self-hosted", "uptime", "uptime-monitoring", "Uptime Kuma"]
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
