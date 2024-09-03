---
title: "PHP-FPM Configurations"
description: "Configuration examples for PHP FastCGI Process Manager (FPM)"
summary: "Configuration examples for PHP FastCGI Process Manager (FPM)"
date: 2020-07-14T00:00:00+01:00
tags: ["linux", "PHP", "PHP-FPM"]
keywords: ["linux", "PHP", "PHP-FPM"]
---

PHP-FPM (FastCGI Process Manager) is an alternative PHP FastCGI implementation with some additional features useful for sites of any size, especially busier sites.

## Install

```bash
apt install php-fpm
```

{{< alert "circle-info" >}}
Detailed guide about how to install PHP on Debian can be found [here](../install/)
{{< /alert >}}
## Configuration

The FPM's main configuration file is `/etc/php/$VERSION/fpm/php.ini`.

### Memory limit

Maximum amount of memory that the PHP script can use.

```bash
memory_limit = 128M
```

### FPM Pool

It is possible to isolate the php codes with fpm pools.

First, create a new user to the new pool:

```bash
adduser --system --ingroup www-data --shell "/sbin/nologin" --no-create-home pooluser
```

Create the new pool file (copy the existing one):

```bash
cp /etc/php/$VERSION/fpm/pool.d/www.conf /etc/php/$VERSION/fpm/pool.d/newpool.conf
```

Modify the new pool's configurations:

```bash
nano /etc/php/$VERSION/fpm/pool.d/newpool.conf
```

```ini
# The section name must be changed from [www]
[newpool]

...

# The user who will be run the process
user = pooluser
group = pooluser

...

# The new pool's socket's name
listen = /run/php/php-fpm-newpool.sock
```
Other configurations may be needed. The above ones are the basics to create a new pool.

Change the files ownership to the new user:

``` bash
chown -R pooluser:pooluser /path/to/code
```
