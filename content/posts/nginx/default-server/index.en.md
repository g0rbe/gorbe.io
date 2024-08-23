---
title: "Default Server Settings for Nginx"
tags: ["nginx", "security", "hardening"]
description: "How to configure a reasonably secure Default Server for Nginx"
---

## Config

```nginx
server {

    listen [::]:443 ssl http2;
    listen 443 ssl http2;

    server_name _;

    ssl_reject_handshake on;
}

server {

    listen 80;
    listen [::]:80;

    server_name _;

    return 444;
}
```

Reload nginx:

```bash
systemctl reload nginx.service
```
