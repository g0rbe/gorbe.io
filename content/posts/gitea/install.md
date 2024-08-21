---
sudebar_label: Install
title: "Install Gitea on Debian 10"
tags: ["Gitea", "selfhost" , "git"]
description: "How to install and configure Gitea on Debian 10 with MariaDB and Nginx."
---

## MariaDB

Install MariaDB:

``` bash
apt install mariadb-server
```

Initialize MariaDB:

``` bash
mysql_secure_installation
```

Create database for Gitea:

``` bash
mysql -u root
```

``` sql
SET old_passwords=0;
CREATE USER 'gitea'@'localhost' IDENTIFIED BY 'S3cureP4ss';
CREATE DATABASE giteadb CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci';
GRANT ALL PRIVILEGES ON giteadb.* TO 'gitea'@'localhost';
FLUSH PRIVILEGES;
```

## Git

Install git:

``` bash
apt install git
```

## Gitea

Download binary:

``` bash
wget -O /usr/bin/gitea https://dl.gitea.io/gitea/1.12.1/gitea-1.12.1-linux-amd64
chmod +x /usr/bin/gitea
```

Verify the binary:

``` bash
gpg --keyserver keys.openpgp.org --recv 7C9E68152594688862D62AF62D9AE806EC1592E2
wget https://dl.gitea.io/gitea/1.12.1/gitea-1.12.1-linux-amd64.asc
gpg --verify /usr/bin/gitea gitea-1.12.1-linux-amd64.asc
```

## User

Create the user for Gitea:

``` bash
adduser --system --group --disabled-password git
```

`/home/git` will be the work directory.

## Directory structure

``` bash
mkdir -p /home/git/{custom,data,log}
chown -R git:git /home/git
chmod -R 750 /home/git
```

## Systemd service

```
[Unit]
Description=Gitea (Git with a cup of tea)
After=syslog.target
After=network.target
Requires=mariadb.service

[Service]
RestartSec=2s
Type=simple
User=git
Group=git
WorkingDirectory=/home/git
ExecStart=/usr/bin/gitea web --config /home/git/app.ini
Restart=always
Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/home/git


[Install]
WantedBy=multi-user.target
```

Copy the code above and create the service:

``` bash
nano /etc/systemd/system/gitea.service
```

Enable and start Gitea:

``` bash
systemctl enable --now gitea.service
```

Check Gitea:

``` bash
systemctl status gitea.service
```

## Nginx

Install Nginx:

``` bash
apt install nginx
```

Example config:

```
# https
server {

        # Enable SSL and HTTP2
        listen [::]:443 ssl http2;
        listen 443 ssl http2;

        # Set certificate path
        ssl_certificate /etc/letsencrypt/live/git.icoman.hu/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/git.icoman.hu/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/git.icoman.hu/fullchain.pem;

        server_name git.icoman.hu;

        # Reverse proxy
        location / {
                proxy_pass http://127.0.0.1:3000;
        }

        # Disable unused methods
        if ($request_method !~ ^(GET|HEAD|POST)$ ) {
                return 405;
        }

}

# http
server {

        listen 80;
        listen [::]:80;
        server_name  git.icoman.hu;

        # Add HSTS header
        add_header Strict-Transport-Security "max-age=63072000; includeSubdomains" always;

        # Redirect http to https
        return 301 https://$host$request_uri;
}

```

### Certbot

Install certbot:

``` bash
apt install certbot python-certbot-nginx
```

Get a cert:

```
certbot certonly --nginx -d example.com --rsa-key-size 4096
```

## Configure

The config file is `/home/git/app.ini`.

### SMTP

Use my mail server with StartTLS to send notifications:

```
[mailer]
ENABLED        = true
FROM           = git@example.com
MAILER_TYPE    = smtp
HOST           = mail.example.com:587
USER           = git@example.com
PASSWD         = `S3cureP4ss`
```

### Require login to see the repos

```
[service]
REQUIRE_SIGNIN_VIEW               = true
```
