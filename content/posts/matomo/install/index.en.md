---
title: Install Matomo
description: How to install Matomo On-Premise with FrankenPHP or nginx/PHP-FPM and MariaDB on Debian Linux.
summary: How to install Matomo On-Premise with FrankenPHP or nginx/PHP-FPM and MariaDB on Debian Linux.
date: 2023-11-17T01:15:02+01:00
tags: [ "Matomo", "analytics"]
keywords: [ "Matomo", "analytics"]
coverAlt: Install Matomo Cover
thumbnailAlt: Matomo Logo
aliases: ["/docs/matomo/install"]
---

## Package


### Requirements

```bash
apt install gpg
```

### Download

Create `/var/www` directory if not exist:

```bash
mkdir -p /var/www
```

Download the latest [Matomo release](https://matomo.org/download/):

```bash
wget -q https://builds.matomo.org/matomo-latest.tar.gz
```

### Verify the archive

Verify the downloaded archive:

```bash
wget -q https://builds.matomo.org/matomo-latest.tar.gz.asc
```

```bash
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys F529A27008477483777FC23D63BB30D0E5D2C749
```

```bash
gpg --verify matomo-latest.tar.gz.asc
```

Should see the **Good signature...** in the output: 

{{< highlight bash "linenos=table,hl_lines=4" >}}
gpg: assuming signed data in 'matomo-latest.tar.gz'
gpg: Signature made Fri 08 Mar 2024 12:36:28 AM CET
gpg:                using RSA key F529A27008477483777FC23D63BB30D0E5D2C749
gpg: Good signature from "Matomo <hello@matomo.org>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: F529 A270 0847 7483 777F  C23D 63BB 30D0 E5D2 C749
{{< / highlight >}}

### Extract the archive

Extract the `tar.gz` archive:

```bash
tar -xf matomo-latest.tar.gz -C /var/www "matomo/"
```

```bash
chown -R www-data:www-data /var/www/matomo/
```

## MariaDB

### Requirements

```bash
apt install mariadb-server
```

### Config

Setup [MariaDB](../../mariadb/setup/index.en.md):

```bash
mysql_secure_installation
```

Create the database and the user:

```bash
mysql --execute="CREATE DATABASE matomo; GRANT ALL PRIVILEGES ON matomo.* TO 'matomo'@'localhost' IDENTIFIED BY 'MATOMO_DB_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
```

## Runing the PHP code

There are two choice to run Matomo's PHP code:

1. Using the classic: [nginx+php-fpm](#nginxphp-fpm)
2. Using a bleeding edge technology: [FrankenPHP](#frankenphp)

### nginx+php-fpm

#### nginx

```bash
apt install nginx
```

```bash
nano /etc/nginx/sites-available/matomo
```

```nginx
server {
    
	listen 80;

    server_name matomo.example.com;

	add_header Referrer-Policy origin always;
	add_header X-Content-Type-Options "nosniff" always;
	add_header X-XSS-Protection "1; mode=block" always;
	add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

    root /var/www/matomo/;

    index index.php;

	location ~ ^/(index|matomo|piwik|js/index|plugins/HeatmapSessionRecording/configs)\.php$ {
		include snippets/fastcgi-php.conf;
		fastcgi_param HTTP_PROXY "";
		fastcgi_pass unix:/var/run/php/php-fpm.sock;
	}

	location ~* ^.+\.php$ {
		deny all;
		return 403;
	}

	location / {
		try_files $uri $uri/ =404;
	}

	location ~ ^/(config|tmp|core|lang) {
		deny all;
		return 403;
	}

	location ~ /\.ht {
		deny  all;
		return 403;
	}

	location ~ js/container_.*_preview\.js$ {
		expires off;
		add_header Cache-Control 'private, no-cache, no-store';
	}

	location ~ \.(gif|ico|jpg|png|svg|js|css|htm|html|mp3|mp4|wav|ogg|avi|ttf|eot|woff|woff2)$ {
		allow all;
		expires 12h;
		add_header Pragma public;
		add_header Cache-Control "public";
	}

	location ~ ^/(libs|vendor|plugins|misc|node_modules) {
		deny all;
		return 403;
	}

	location ~/(.*\.md|LEGALNOTICE|LICENSE) {
		default_type text/plain;
	}
}
```

#### PHP-FPM

[Install PHP 8](../../php/install.md) than install the requirements:

```bash
apt install php-fpm php-curl php-gd php-mysql php-xml php-mbstring
```

### FrankenPHP

Install [FrankenPHP](../../frankenphp/install/index.en.md):

```bash
wget -q -O- 'https://gorbe.io/posts/frankenphp/install/script.sh' | bash -x -
```

Change the owner and the group of the PHP files:

```bash
chown -R frankenphp:frankenphp /var/www/matomo/
```

Configure the [Caddyfile](../../frankenphp/configure/index.en.md#matomo) :

```bash
nano /etc/frankenphp/Caddyfile
```

```caddy
{
	frankenphp
	order php_server before file_server

	servers matomo.example.com {
		trusted_proxies static 1.2.3.4
	}
}

matomo.example.com {

	@private-dirs {
		path /config/*
		path /tmp/*
		path /lang/*
	}

	respond @private-dirs 403 {
		close
	}

	root * /var/www/matomo
	php_server
}
```

```bash
systemctl restart frankenphp
```