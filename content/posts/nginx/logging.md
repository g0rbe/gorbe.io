---
sidebar_label: Logging
title: "Nginx Logging Configurations"
categories: ["nginx", "log"]
description: "Nginx Logging Configurations"
---

## Format

### Combined

:::note
This is the default log format in Nginx.
:::

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
