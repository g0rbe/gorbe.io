---
title: "Nginx Logging Configurations"
description: "Nginx Logging Configurations"
summary: "Nginx Logging Configurations"
date: 2024-01-31T01:49:32+01:00
tags: ["nginx", "log"]
keywords: ["nginx", "log"]
thumbnailAlt: Nginx Logo
---

## Format

### Combined

{{< alert "circle-info" >}}
This is the default log format in Nginx.
{{< /alert >}}

```nginx
log_format combined '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
```

### Vhost Combined

```nginx title="/etc/nginx/conf.d/logging.conf"
log_format vhost_combined '$host $remote_addr - $remote_user [$time_local] '
                          '"$request" $status $body_bytes_sent '
                          '"$http_referer" "$http_user_agent"';

access_log /var/log/nginx/access.log vhost_combined;
error_log  /var/log/nginx/error.log;
```
