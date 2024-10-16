---
title: Install WordPress
description: Install WordPress with MariaDB and nginx on Debian server.
summary: Install WordPress with MariaDB and nginx on Debian server.
date: 2024-10-16T12:26:16+02:00
tags: ["WordPress", "MariaDB", "nginx", "php"]
keywords: ["WordPress", "MariaDB", "nginx", "php"]
# featureAlt:
thumbnailAlt: WordPress Logo
coverAlt: Install WordPress Cover
draft: true
# aliases: ['/']
---

## Create the user and the group

Create the group first:

```bash
groupadd --system example_com
```

Create the user:

```bash
useradd --system --gid="example_com" --no-create-home --shell="/usr/sbin/nologin" example_com
```

Add `www-data` user to the new group:

```bash
usermod -aG example_com www-data
```

## MySQL

Create the user and the DB:

```bash
mysql --execute="CREATE DATABASE example_com; GRANT ALL PRIVILEGES ON example_com.* TO 'wpuser'@'localhost' IDENTIFIED BY 'SECURE_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
```

## Files

### Download and extract

Download the latest version:

```bash
wget "https://wordpress.org/latest.tar.gz"
```

Extract to `/var/www/`:

```bash
tar -xf "latest.tar.gz" -C "/var/www/"
```

Rename the `wordpress` directory to the used domain:

```bash
mv /var/www/wordpress /var/www/example.com
```

### `wp-config.php`

Create the `wp-config.php`:

```bash
cp "/var/www/example.com/wp-config-sample.php" "/var/www/example.com/wp-config.php"
```

Change the permission:

```bash
chmod 0640 "/var/www/example.com/wp-config.php"
```

Configure the WordPress:

```bash
nano "/var/www/example.com/wp-config.php"
```

### Owner and group

Change the owner and the group of the files:

```bash
chown -R example_com:example_com /var/www/
```

## PHP-FPM

Create a new pool

```bash
cp /etc/php/8.3/fpm/pool.d/www.conf /etc/php/8.3/fpm/pool.d/example_com.conf 
```

```bash
nano /etc/php/8.3/fpm/pool.d/example_com.conf
```

## nginx


```bash
nano /etc/nginx/sites-available/example.com
```

```nginx
server {

        # Enable SSL and HTTP2
        listen [::]:443 ssl http2;
        listen 443 ssl http2;

        # Set certificate path
        ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/example.com/fullchain.pem;

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
        add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload" always;

        # Set root path
        root /var/www/example.com;
        index  index.php index.html index.htm;
        server_name  example.com;

        # max file size to upload
        client_max_body_size 100M;

        proxy_buffering off;

        location / {
                try_files $uri $uri/ /index.php?$args;
        }

        # FastCGI
        location ~ \.php$ {

                #NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
                include fastcgi_params;
                fastcgi_intercept_errors on;
                fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
                fastcgi_pass    unix:/run/php/php8.3-example_com.sock;
                include         snippets/fastcgi-php.conf;
        }

        location ~* \.(js|css|png|jpg|jpeg|gif|ico|webp|ttf|woff2)$ {
                expires 365d;
        }

        location ~ /\. {
                deny all;
        }
}

server {

        listen 80;
        listen [::]:80;

        server_name  example.com;

        return 301 https://$host$request_uri;
}

# https
server {

        # Enable SSL and HTTP2
        listen [::]:443 ssl http2;
        listen 443 ssl http2;

        server_name www.example.com;

        # Set certificate path
        ssl_certificate /etc/letsencrypt/live/www.example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/www.example.com/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/www.example.com/fullchain.pem;

        add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload" always;

        # Enable OCSP
        ssl_stapling on;
        ssl_stapling_verify on;
        resolver 1.1.1.1 1.0.0.1;
        resolver_timeout 5s;

        # Disable accessing hidden files except .well-known
        location ~ /\.(?!well-known).* {
                deny all;
        }

        return 301 https://example.com$request_uri;
}

# http
server {

        listen 80;
        listen [::]:80;
        server_name www.example.com;

        # Redirect http to https
        return 301 https://example.com$request_uri;
}
```

Enable:

```bash
ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/
```

Reload nginx:

```bash
systemctl reload nginx
```