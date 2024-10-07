---
title: Set up an Onion Service
description: How to set up an onion service on Debian
summary: How to set up an onion service on Debian
date: 2024-08-22T03:54:32+02:00
tags: ["tor", "security"]
keywords: ["tor", "security"]
draft:  true
thumbnailAlt: Tor Logo
---

## `torrc`

Edit the `torrc`:

```bash
nano /etc/tor/torrc
```

Add these lines:

```bash
HiddenServiceDir /var/lib/tor/my_website/
HiddenServicePort 80 127.0.0.1:80
```

Restart `tor` service:

```bash
systemctl restart tor@default
```

## Web Server

{{< alert "circle-info" >}}
The `Onion-Location` header can be used to advertise the onion site.
{{< /alert >}}

### nginx

```nginx
server {
    listen 80;
    server_name <your-onion-address>.onion;
    index index.html;
    root /var/www/<your-onion-address>.onion;
}
```

### Caddy

{{< alert "triangle-exclamation" >}}
The `http://` prefix is required to disable the automatic TLS.
{{< /alert >}}

```caddy
http://<your-onion-address>.onion {
        root * /var/www/<your-onion-address>.onion
        file_server *
}
```