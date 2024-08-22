---
title: "Install Ghost"
description: "How to install and configure Ghost CMS on Debian 10 with MariaDB and Nginx."
summary: "How to install and configure Ghost CMS on Debian 10 with MariaDB and Nginx."
date: 2020-06-25T00:00:00+01:00
categories: ["Ghost", "selfhost" ]
keywords: ["Ghost", "selfhost" ]
draft:  false
---


## Create user for Ghost

``` bash
adduser [GHOSTUSER]
usermod -aG sudo [GHOSTUSER]
```

## Requirements

### Nginx

Install nginx:

``` bash
apt install nginx -y
```

### MariaDB

Install MariaDB

``` bash
apt install mariadb-server mariadb-client -y
```

Initialize MariaDB: 

``` bash
mysql_secure_installation
```

Create database for Ghost:

``` bash
mysql -u root -p
```

``` sql
CREATE USER [GHOSTUSER]@localhost IDENTIFIED BY "Str0ngP4ss";
CREATE DATABASE  [GHOSTDB]; 
GRANT ALL ON [GHOSTDB].* TO [GHOSTUSER]@localhost;
FLUSH PRIVILEGES;
QUIT;
```

### NodeJS 12.x

Install NodeJS 12.x:

``` bash
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash
apt install nodejs -y
```

## Create directory

``` bash
mkdir -p /var/www/ghost
chown [GHOSTUSER]:[GHOSTUSER] /var/www/ghost
chmod 775 /var/www/ghost
```

## Ghost CLI

``` bash
npm install ghost-cli@latest -g
```

## Ghost

Change user to `[GHOSTUSER]`:

``` bash
su - [GHOSTUSER]

```

Install our Ghost:

``` bash
cd /var/www/ghost
ghost install
```
