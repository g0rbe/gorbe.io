---
title: "Install PHP on Debian"
date: 2023-12-16T01:01:11+01:00
description: "Installing PHP on Debian: A Comprehensive Guide"
aliases: ["docs/php/install"]
tags: [ "PHP"]
keywords: [ "PHP"]
aliases: ["/docs/php/install"]
---

PHP is a crucial component for web development, and having the latest version ensures access to the newest features and security updates. Debian 12, known for its stability and reliability, is a popular choice for hosting PHP-based applications. This post guides you through installing the latest PHP version on Debian 12.

## TLDR

```bash
sudo apt install -y lsb-release apt-transport-https ca-certificates curl && \
sudo wget -O "/etc/apt/trusted.gpg.d/php.gpg" "https://packages.sury.org/php/apt.gpg" && \
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee "/etc/apt/sources.list.d/php.list" && \
sudo apt update
```

## Pre-Installation Steps

Before beginning the installation, it's important to update your system:

```bash
sudo apt update && sudo apt upgrade
```

These commands will update your package list and upgrade existing packages to their latest versions.

## Adding a Third-Party Repository

Debian’s default repositories might not always contain the latest PHP version.
To access the most recent release, you'll need to add a [third-party repository maintained by Ondřej Surý](https://deb.sury.org/), a well-known PHP maintainer:

```bash
sudo apt install lsb-release apt-transport-https ca-certificates curl
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
```

This sequence adds the necessary GPG key and repository for the latest PHP versions.

## Installing the Latest PHP

First, update your package list:

```bash
sudo apt update
```

Then, install the latest PHP version available in the repository:

```bash
sudo apt install php
```

  *NOTE*: `php` and `php-fpm` packages are dependency packages, which depends on latest stable PHP version.

Optionally, you can install additional PHP modules based on your requirements:

```bash
sudo apt install php-cli php-fpm php-mysql php-xml php-curl ...
```
