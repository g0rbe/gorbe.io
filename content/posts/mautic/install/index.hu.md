---
title: "Mautic Telepítése a Production Package használatával"
description: "A Mautic Telepítése a Production Package használatával Debian 12 rendszerre, Apache, PHP-FPM és MariaDB használatával."
summary: "A Mautic Telepítése a Production Package használatával Debian 12 rendszerre, Apache, PHP-FPM és MariaDB használatával."
date: 2024-03-19T03:18:31+01:00
tags: ["mautic", "apache", "PHP", "MariaDB", "marketing", "newsletter", "email-marketing", "email-campaigns", "marketing-tools", "marketing-automation"]
keywords: ["mautic", "apache", "PHP", "MariaDB", "marketing", "newsletter", "email-marketing", "email-campaigns", "marketing-tools", "marketing-automation"]
aliases: ["/hu/docs/mautic/install"]
---

## A PHP 8.1 Telepítése

A Mautic 5.0-hoz PHP 8.0 vagy 8.1 szükséges.

Telepítse [Sury Debian repository-ját](/posts/php/install/):

```bash
sudo apt install -y lsb-release apt-transport-https ca-certificates curl && \
sudo wget -O "/etc/apt/trusted.gpg.d/php.gpg" "https://packages.sury.org/php/apt.gpg" && \
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee "/etc/apt/sources.list.d/php.list" && \
sudo apt update
```

## Telepítse a szükséges csomagokat

Telepítse a függőségeket:

```bash
apt install apache2 mariadb-server php8.1 php8.1-{fpm,xml,mysql,imap,zip,intl,curl,gd,mbstring,bcmath} unzip
```

## A MariaDB konfigurálása

```bash
mysql_secure_installation
```

Hozza létre a DB-t és a felhasználót:

Hozzon létre egy véletlenszerű jelszót az adatbázishoz, és tárolja azt egy környezeti változóban:

```bash
MYSQL_PASSWD=$(echo $RANDOM | md5sum | head -c 20)
```

Az adatbázis jelszavának kiírása:

```bash
echo $MYSQL_PASSWD
```

Hozza létre az adatbázist és a felhasználót:

```bash
mysql --execute="CREATE DATABASE mautic; GRANT ALL PRIVILEGES ON mautic.* TO 'mautic'@'localhost' IDENTIFIED BY '${MYSQL_PASSWD}' WITH GRANT OPTION; FLUSH PRIVILEGES;"
```

## A PHP-FPM konfigurálása

Állítsa be a PHP-FPM ajánlott beállításait:

```bash
nano +c/date.timezone /etc/php/8.1/fpm/php.ini
```

```ini
date.timezone = Europe/Budapest
```

:::warning
Módosítsa az alábbi értékeket igényei szerint!
:::

```bash
sed -i 's/memory_limit = 128M/memory_limit = 512M/' /etc/php/8.1/fpm/php.ini && \
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php/8.1/fpm/php.ini && \
sed -i 's/max_execution_time = 30/max_execution_time = 600/' /etc/php/8.1/fpm/php.ini && \
sed -i 's/post_max_size = 8M/post_max_size = 64M/' /etc/php/8.1/fpm/php.ini
```

Indítsa újra a PHP-FPM szolgáltatást a beállítások alkalmazásához:

```bash
systemctl restart php8.1-fpm.service
```

## Apache

Hozd létre a webhely konfigurációját:

```bash
nano /etc/apache2/sites-available/mautic.conf
```

```apache
<VirtualHost *:80>

    ServerName mautic.example.com
    DocumentRoot /var/www/mautic/

    <Directory />
        Options FollowSymLinks
        AllowOverride All
    </Directory>

    <Directory /var/www/mautic/>
        Options FollowSymLinks MultiViews
        AllowOverride All
        Order allow,deny
        allow from all
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
```

Az `mpm_prefork` letiltása:

```bash
sudo a2dismod mpm_prefork
```

Engedélyezze a szükséges Apache modulokat:

```bash
a2enmod rewrite mpm_event proxy_fcgi setenvif
```

PHP-FPM engedélyezése Apache számára:

```bash
a2enconf php8.1-fpm
```

A webhely engedélyezése:

```bash
a2ensite mautic.conf
```

Beállítások alkalmazása Apache-hoz:

```bash
systemctl restart apache2
```

## Telepítse a Mautic-ot

Töltse le a [legfrissebb archívumot](https://github.com/mautic/mautic/releases/latest):

```bash
wget https://github.com/mautic/mautic/releases/download/5.0.4/5.0.4.zip
```

Hozza létre a Mautic könyvtárát:

```bash
mkdir /var/www/mautic
```

A zip-archívum kibontása:

```bash
unzip -d /var/www/mautic/ 5.0.4.zip
```

Módosítsa a fájlok tulajdonosát:

```bash
chown -R www-data:www-data /var/www/mautic
```