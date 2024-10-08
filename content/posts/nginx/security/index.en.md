---
title: Nginx Security
description: Security settings of nginx
summary: Security settings of nginx
date: 2024-10-08
tags: ["nginx", "webserver", "security", "tls", "log"]
keywords: ["nginx", "webserver", "security", "tls", "log"]
draft:  true
thumbnailAlt: Nginx Logo
#aliases: []
---

## HSTS

```nginx
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
```

## Content Security Policy

```nginx
add_header Content-Security-Policy "default-src https: 'unsafe-inline'" always;
```