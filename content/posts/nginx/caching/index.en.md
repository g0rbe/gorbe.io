---
title: "Nginx Caching Configurations"
description: "How to configure content caching in Nginx"
summary: "How to configure content caching in Nginx"
date: 2024-08-21
tags: ["nginx", "cache", "performance"]
keywords: ["nginx", "cache", "performance"]
thumbnailAlt: Nginx logo
draft:  false
---

Create directory for caching:
```bash
mkdir /var/cache/nginx
```

Edit `/etc/nginx/conf.d/cache.conf`:

```nginx
# Cache config
proxy_cache_path /var/cache/nginx levels=1:2 use_temp_path=off keys_zone=cache:10m inactive=14d max_size=8G;

# Cached item is valid for 10 minutes
#proxy_cache_valid 10m;

# use proxy if upstream not working
#proxy_cache_use_stale error timeout updating http_502 http_503 http_504 http_429;

# Update in the background
#proxy_cache_revalidate on;
proxy_cache_background_update on;

#Enable caching
proxy_cache cache;

proxy_cache_lock on;
proxy_cache_lock_age 20s;
proxy_cache_lock_timeout 5s;
```
## `Cache-Control`


```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js|webp)$ {
    etag off;
    if_modified_since off;
    expires 30d;
    add_header Cache-Control "public";
}
```
