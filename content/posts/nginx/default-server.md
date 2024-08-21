---
sidebar_label: Default Server
title: "Default Server Settings for Nginx"
tags: ["nginx", "security", "hardening"]
description: "How to configure a reasonably secure Default Server for Nginx"
---

## Create a self-sgined certificate

```bash
openssl req -x509 -nodes -newkey rsa:4096 -keyout /etc/ssl/private/nginx-key.pem -out /etc/ssl/private/nginx-cert.pem -days 1825
```

## nginx

```nginx
server {

    listen [::]:443 ssl http2;
    listen 443 ssl http2;

    server_name _;

    ssl_certificate /etc/ssl/private/nginx-cert.pem;
    ssl_certificate_key /etc/ssl/private/nginx-key.pem;

    return 444;
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
