---
sidebar_label: Install with Composer
title: "Install Mautic 5 with Composer on Debian 12"
tags: ["mautic", "apache", "php","composer", "mariadb", "marketing", "newsletter", "email-marketing", "email-campaigns", "marketing-tools", "marketing-automation"]
description: "How to Install Mautic 5 with Composer on Debian 12 with Apache, PHP-FPM and MariaDB"
---

## Install repository for PHP 8.1

Mautic 5.0 requires PHP 8.0 or 8.1.

Install Sury's Debian repository:

```bash
sudo apt install -y lsb-release apt-transport-https ca-certificates curl && \
sudo wget -O "/etc/apt/trusted.gpg.d/php.gpg" "https://packages.sury.org/php/apt.gpg" && \
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee "/etc/apt/sources.list.d/php.list" && \
sudo apt update
```

## Install repository for NodeJS / NPM

NPM will be required by Composer.

Install the LTS (20.x) NodeJS Debian repository:

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
```

## Install required packages

Install the dependencies:

```bash
apt install apache2 mariadb-server php8.1 php8.1-{fpm,xml,mysql,imap,zip,intl,curl,gd,mbstring,bcmath} nodejs unzip git
```

## Configure MariaDB

```bash
mysql_secure_installation
```

Create the DB and the user:

Generate a random password for the database and store it in an environment variable:

```bash
MYSQL_PASSWD=$(echo $RANDOM | md5sum | head -c 20)
```

To print the database password:

```bash
echo $MYSQL_PASSWD
```

Create the database and the user:

```bash
mysql --execute="CREATE DATABASE mautic; GRANT ALL PRIVILEGES ON mautic.* TO 'mautic'@'localhost' IDENTIFIED BY '${MYSQL_PASSWD}' WITH GRANT OPTION; FLUSH PRIVILEGES;"
```

## Composer

Install the latest Composer:

```bash
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
php composer-setup.php && \
php -r "unlink('composer-setup.php');" && \
sudo mv composer.phar /usr/local/bin/composer
```

## Configure PHP-FPM

Configure the recommended settings for PHP-FPM:

```bash
nano +c/date.timezone /etc/php/8.1/fpm/php.ini
```

```ini
date.timezone = Europe/Budapest
```

:::warning
Modify the values below to your needs!
:::

```bash
sed -i 's/memory_limit = 128M/memory_limit = 512M/' /etc/php/8.1/fpm/php.ini && \
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php/8.1/fpm/php.ini && \
sed -i 's/max_execution_time = 30/max_execution_time = 600/' /etc/php/8.1/fpm/php.ini && \
sed -i 's/post_max_size = 8M/post_max_size = 64M/' /etc/php/8.1/fpm/php.ini
```

Restart the PHP-FPM service to apply the settings:

```bash
systemctl restart php8.1-fpm.service
```

## Apache

Create the site config:

```bash
nano /etc/apache2/sites-available/mautic.conf
```

```apache
<VirtualHost *:80>

    ServerName mautic.example.com
    DocumentRoot /var/www/mautic/docroot/

    <Directory />
        Options FollowSymLinks
        AllowOverride All
    </Directory>

    <Directory /var/www/mautic/docroot/>
        Options FollowSymLinks MultiViews
        AllowOverride All
        Order allow,deny
        allow from all
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
```

Disable `mpm_prefork`:

```bash
sudo a2dismod mpm_prefork
```

Enable the required Apache modules:

```bash
a2enmod rewrite mpm_event proxy_fcgi setenvif
```

Enable PHP-FPM for Apache:

```bash
a2enconf php8.1-fpm
```

Enable the site:

```bash
a2ensite mautic.conf
```

Apply settings for Apache:

```bash
systemctl restart apache2
```


## Install Mautic

Install Mautic to `/var/www/mautic/`:

```bash
COMPOSER_ALLOW_SUPERUSER=1 composer create-project mautic/recommended-project:^5.0 /var/www/mautic --no-interaction
```

Change the owner of the files:

```bash
chown -R www-data:www-data /var/www/mautic
```
