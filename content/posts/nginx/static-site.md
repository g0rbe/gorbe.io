---
title: "Setup Nginx to host a Static Site"
description: "A reasonably secure Nginx config for static site hosting with TLS using Let's Encrypt certificate."
summary: "A reasonably secure Nginx config for static site hosting with TLS using Let's Encrypt certificate."
date: 2024-03-04T10:42:24+01:00
tags: ["nginx"]
keywords: ["nginx"]
---


```nginx title="/etc/nginx/site-available/www.example.com"
# https://www.example.com
server {

    # Enable SSL and HTTP2
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    server_name www.example.com;

    # Set certificate path
    ssl_certificate /etc/letsencrypt/live/www.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/www.example.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/www.example.com/fullchain.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305;
    ssl_prefer_server_ciphers on;
    ssl_conf_command Options ServerPreference;
    ssl_conf_command Ciphersuites TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256;

    # Enable OCSP
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 1.1.1.1 1.0.0.1;
    resolver_timeout 5s;

    # Add security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload" always;

    # Set root path
    root /var/www/www.example.com/;
    index index.html;

    location / {  
        try_files $uri $uri/ =404;
    }
	
    # Cache static content
    location ~* \.(css|js|png|jpg|webp)$ {
        expires max;
        add_header Cache-Control "public";
    }

    # Disable accessing hidden files except .well-known
    location ~ /\.(?!well-known).* {
        deny all;
    }

    # Disable unused methods
    if ($request_method !~ ^(GET|HEAD)$ ) {
        return 405;
    }

    error_page 404 /404.html;
}

# http://www.example.com
# Redirects to https://www.example.com
server {

    listen 80;
    listen [::]:80;
    server_name  www.example.com;

    # Redirect http to https
    return 301 https://$host$request_uri;
}

# https://example.com
# Redirects to https://www.example.com
server {

    # Enable SSL and HTTP2
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    # Set certificate path
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/example.com/fullchain.pem;

    server_name example.com;

	# Add HSTS header
    add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload" always;

    # Redirect http to https
    return 301 https://www.$host$request_uri;
}

# http://example.com
# Redirects to https://www.example.com
server {

    listen 80;
    listen [::]:80;
    server_name  example.com;

    # Redirect http to https
    return 301 https://www.$host$request_uri;
}
```
