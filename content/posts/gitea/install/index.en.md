---
title: "Install Gitea"
description: "How to install and configure Gitea on Debian 12 with MariaDB and Nginx."
summary: "How to install and configure Gitea on Debian 12 with MariaDB and Nginx."
date: 2020-07-01
tags: ["Gitea", "selfhost" , "git"]
keywords: ["Gitea", "selfhost" , "git"]
#featureAlt:
#draft:  false
coverAlt: Install Gitea 
thumbnailAlt: "Gitea logo"
aliases: ["/docs/gitea/install"]
---


## Git

Install git:

``` bash
apt install git
```

## User

Create the user for Gitea:

``` bash
adduser --system --group --disabled-password --home /home/gitea gitea
```

`/home/gitea` will be the work directory.

## MariaDB

Install MariaDB:

```bash
apt install mariadb-server
```

Initialize MariaDB:

```bash
mysql_secure_installation
```

Create database for Gitea:

```bash
mysql -u root
```

```sql
SET old_passwords=0;
CREATE DATABASE gitea CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci';
GRANT ALL PRIVILEGES ON gitea.* TO 'gitea'@'localhost' IDENTIFIED BY 'S3cureP4ss' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

## Binary

Download binary:

```bash
wget -O gitea "https://dl.gitea.com/gitea/1.22.6/gitea-1.22.6-linux-amd64"
```
```bash
install gitea /home/gitea
```


## Systemd service

```systemd
[Unit]
Description=Gitea (Git with a cup of tea)
After=network.target
Requires=mariadb.service

[Service]
RestartSec=2s
Type=simple
User=gitea
Group=gitea
WorkingDirectory=/home/gitea
ExecStart=/home/gitea/gitea web
Restart=always

[Install]
WantedBy=multi-user.target
```

Copy the code above and create the service:

```bash
nano /etc/systemd/system/gitea.service
```

Enable and start Gitea:

```bash
systemctl enable --now gitea.service
```

Check Gitea:

```bash
systemctl status gitea.service
```

## Nginx

### Install

Install Nginx:

```bash
apt install nginx
```

Example config:

```nginx
server {

        # Enable SSL and HTTP2
        listen [::]:443 ssl http2;
        listen 443 ssl http2;

        # Set certificate path
        ssl_certificate /etc/letsencrypt/live/git.example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/git.example.com/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/git.example.com/fullchain.pem;

        server_name git.example.com;

        # Enable OCSP
        ssl_stapling on;
        ssl_stapling_verify on;
        resolver 1.1.1.1 1.0.0.1;
        resolver_timeout 5s;

        # Add security headers
        #add_header X-Frame-Options "SAMEORIGIN" always;
        #add_header X-Content-Type-Options "nosniff" always;
        #add_header Referrer-Policy 'strict-origin' always;
        #add_header X-XSS-Protection "1; mode=block" always;
        add_header Strict-Transport-Security "max-age=63072000; includeSubdomains" always;

        # Reverse proxy
        location / {
                client_max_body_size 512M;

                proxy_set_header Connection $http_connection;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;

                proxy_pass http://127.0.0.1:3000;
        }
}

server {

        listen 80;
        listen [::]:80;
        server_name  git.example.com;

        # Redirect http to https
        return 301 https://$host$request_uri;
}
```


### Certbot

Install certbot:

``` bash
apt install certbot python3-certbot-nginx
```

Get a cert:

```bash
certbot certonly --nginx -d git.example.com --rsa-key-size 4096
```

### Start

```bash
ln -s /etc/nginx/sites-available/git.example.com /etcx/nginx/sites-enabled/
```

```bash
systemctl enable --now nginx
```