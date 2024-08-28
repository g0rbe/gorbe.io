---
title: Install Matomo with FrankenPHP and MariaDB on Debian Linux
tags: [ "analytics"]
description: How to install Matomo On-Premise with FrankenPHP and MariaDB on Debian Linux.
date: 2023-11-17T01:15:02+01:00
---

## Requirements

```bash
apt install mariadb-server gpg
```

## Download

Create `/var/www` directory if not exist:

```bash
mkdir -p /var/www
```

Download the latest [Matomo release](https://matomo.org/download/):

```bash
wget -q https://builds.matomo.org/matomo-latest.tar.gz
```

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

```bash

gpg: assuming signed data in 'matomo-latest.tar.gz'
gpg: Signature made Fri 08 Mar 2024 12:36:28 AM CET
gpg:                using RSA key F529A27008477483777FC23D63BB30D0E5D2C749
# highlight-next-line
gpg: Good signature from "Matomo <hello@matomo.org>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: F529 A270 0847 7483 777F  C23D 63BB 30D0 E5D2 C749
```

Extract the `tar.gz` archive:

```bash
tar -xf matomo-latest.tar.gz -C /var/www "matomo/"
```

## MariaDB

Setup [MariaDB](../mariadb/setup/index.en.md):

```bash
mysql_secure_installation
```

Create the database and the user:

```bash
{`mysql --execute="CREATE DATABASE matomo; GRANT ALL PRIVILEGES ON matomo.* TO 'matomo'@'localhost' IDENTIFIED BY 'MATOMO_DB_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"`}
```

## FrankenPHP

Install [FrankenPHP](../frankenphp/install/index.en.md):

```bash
wget -q -O- 'https://gorbe.io/assets/docs/frankenphp/install/frankenphp-install.sh' | bash -x -
```

Change the owner and the group of the PHP files:

```bash
chown -R frankenphp:frankenphp /var/www/matomo/
```

Configure the [Caddyfile](../frankenphp/configure/index.en.md#matomo) :

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