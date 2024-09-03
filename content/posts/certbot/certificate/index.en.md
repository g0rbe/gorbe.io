---
title: Obtain SSL Certificate(s) with Certbot
description: "Use Certbot to obtain free TLS certificate from Let's Encrypt."
summary: "Use Certbot to obtain free TLS certificate from Let's Encrypt."
date: 2024-04-19
# lastmod: {{ .Date }}
tags: ["certbot", "ssl", "tls", "encryption", "security"]
keywords: ["certbot", "ssl", "tls", "encryption", "security"]
thumbnailAlt: "Certbot logo"
draft:  false
aliases: ["/docs/certbot/certificate"]
---

## Nginx

### RSA-4096

```bash
certbot certonly --nginx -d example.com --key-type rsa --rsa-key-size 4096
```
