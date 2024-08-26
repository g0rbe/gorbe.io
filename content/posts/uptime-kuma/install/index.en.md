---
title: "Install Uptime Kuma from Source"
description: "Install Uptime Kuma from Source with Nginx on Debian 12"
date: 2023-11-15T03:43:49+01:00
tags: ["monitor", "monitoring", "selfhosted", "self-hosted", "uptime", "uptime-monitoring", "Uptime Kuma"]
keywords: ["monitor", "monitoring", "selfhosted", "self-hosted", "uptime", "uptime-monitoring", "Uptime Kuma"]
aliases: ["/docs/uptime-kuma/install-from-source"]
---

Source: https://github.com/louislam/uptime-kuma

## Install

Install Uptime Kuma with Nginx and systemd.

### Dependencies

NodeJS

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
```

```bash
apt-get install -y nodejs
```

Install Git, Nginx and Certbot:

```bash
apt install git nginx python3-certbot-nginx
```

Create a user for Uptime Kuma:
```bash
adduser --disabled-password --disabled-login --gecos "" uptime
```

### Setup

```bash
cd /var/www
```

```bash
git clone https://github.com/louislam/uptime-kuma.git uptime.example.com
```

Change the owner/group of the files:
```bash
chown -R uptime:uptime uptime.example.com
```

Change the current user:
```bash
sudo -u uptime /bin/bash
```

Run the setup:
```bash
npm run setup
```

Get a certificate from Let's Encrypt:
```bash
certbot certonly --nginx -d uptime.example.com --rsa-key-size 4096
```

Configure Nginx:
```nginx
# https
server {

        # Enable SSL and HTTP2
        listen 443 ssl http2;

        server_name uptime.example.com;

        access_log /var/log/nginx/access.log;

        # Set certificate path
        ssl_certificate /etc/letsencrypt/live/uptime.example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/uptime.example.com/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/uptime.example.com/fullchain.pem;

	    # Enable OCSP
	    ssl_stapling on;
	    ssl_stapling_verify on;
	    resolver 1.1.1.1 1.0.0.1;
	    resolver_timeout 5s;

        # Add security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy 'strict-origin' always;
        add_header Strict-Transport-Security "max-age=63072000" always;

        # Reverse proxy
        location / {
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";

                proxy_pass http://127.0.0.1:3001;
        }
}

# http
server {

        listen 80;
        server_name  uptime.example.com;

        # Redirect http to https
        return 301 https://$host$request_uri;
}
```

Create a systemd service:
```bash
nano /etc/systemd/system/uptime.service
```

```bash
[Unit]
Description=Uptime-Kuma - A free and open source uptime monitoring solution
Documentation=https://github.com/louislam/uptime-kuma
After=network.target

[Service]
Type=simple
User=uptime
Group=uptime
WorkingDirectory=/var/www/uptime.example.com
ExecStart=/usr/bin/npm run start-server
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload
```

```bash
systemctl enable --now uptime.service
```

:::tip
Dont forget the [default nginx configurations](../../nginx/configurations/)
:::
