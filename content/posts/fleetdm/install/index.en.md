---
title: Install Fleet
description: How to install Fleet on Debian Linux server.
summary: How to install Fleet on Debian Linux server.
date: 2025-01-20T22:33:59+01:00
tags: ["fleet", "mdm", "device-management", "endpoint-security", "vulnerability-management"]
keywords: ["fleet", "mdm", "device-management", "endpoint-security", "vulnerability-management"]
# featureAlt:
thumbnailAlt: "Fleet Logo"
coverAlt: "Cover for Install Fleet"
# draft:  true
# aliases: ['/']
---

## Dependencies

Install requirements from `apt`:

```bash
apt install redis nginx python3-certbot-nginx gnupg
```

### MySQL

#### Install

[Install MySQL Community Server](../../mysql/install/index.en.md) via `apt`:

```bash
wget "https://dev.mysql.com/get/mysql-apt-config_0.8.33-1_all.deb"
```

```bash
dpkg -i "mysql-apt-config_0.8.33-1_all.deb"
```

```bash
apt update && apt install mysql-community-server
```

#### Configure

{{< alert >}}
Dont forget to change the password!
{{< /alert >}}

[Setup a new database and user](../../mysql/setup.md):

```bash
export MYSQL_PASSWD="$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16; echo)"
```

```bash
mysql --execute="CREATE DATABASE fleet; CREATE USER 'fleet'@'localhost' IDENTIFIED BY '${MYSQL_PASSWD}'; GRANT ALL PRIVILEGES ON fleet.* TO 'fleet'@'localhost'; FLUSH PRIVILEGES;"
```

### Redis

Nothing to config on localhost.

### Certbot

```bash
certbot certonly --nginx -d fleet.example.com
```

{{< alert "circle-info" >}}
The default key algorithm from version  `2.0.0` is `ECDSA`. See here [how to generate RSA key](../../certbot/certificate/#rsa-4096).
{{< /alert >}}

### Nginx

```bash
nano /etc/nginx/sites-available/fleet.example.com
```

Template for site config:

```nginx                                                                                                        
server {

        listen 443 ssl http2;
        listen [::]:443 ssl http2;

        server_name fleet.example.com;

        ssl_certificate /etc/letsencrypt/live/fleet.example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/fleet.example.com/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/fleet.example.com/fullchain.pem;

        ssl_stapling on;
        ssl_stapling_verify on;
        resolver 1.1.1.1 1.0.0.1;
        resolver_timeout 5s;

        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy 'strict-origin' always;
        add_header Strict-Transport-Security "max-age=63072000" always;

           location / {
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";

                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;

                proxy_pass http://127.0.0.1:8080;
        }
}

server {

        listen 80;
        listen [::]:80;

        server_name  fleet.example.com;

        return 301 https://$host$request_uri;
}
```


```bash
ln -s /etc/nginx/sites-available/fleet.example.com /etc/nginx/sites-enabled/
```

{{< alert "circle-info" >}}
This is just the site config.
Check the [other configurations for nginx](tags/nginx/)
{{< /alert >}}

### User and Group

Create the group first:

```bash
groupadd --system "fleet"
```

Create the `fleet` user:

```bash
useradd --system --gid="fleet" --create-home  --home-dir="/var/lib/fleet" --shell="/usr/sbin/nologin" "fleet"
```

## Binary

Download the binary:

```bash
wget 'https://github.com/fleetdm/fleet/releases/download/fleet-v4.62.1/fleet_v4.62.1_linux.tar.gz'
```

Extract the archive:

```bash
tar -xvf "fleet_*_linux.tar.gz"
```

Install the binary:

```bash
install fleet_*_linux/fleet /usr/local/bin/
```

Remove the leftover files:

```bash
rm -r fleet_*_linux*
```

## Config

Create the directory:

```bash
install -o fleet -g fleet -d /etc/fleet
```
  
Dump the config:

```bash
sudo -u fleet fleet config_dump > /etc/fleet/config.yaml
```

## systemd

```bash
nano /etc/systemd/system/fleet.service
```

```systemd
[Unit]
Description=Fleet
After=network.target

[Service]
User=fleet
Group=fleet
LimitNOFILE=8192
ExecStart=/usr/local/bin/fleet serve --config /etc/fleet/config.yaml

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload
```

## Prepare

```bash
sudo -u fleet /usr/local/bin/fleet prepare db --config /etc/fleet/config.yaml
```

## Start

```bash
systemctl enable --now fleet
```