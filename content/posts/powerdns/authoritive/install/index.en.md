---
title: Install Authoritative PowerDNS
description: How to install Authoritative PowerDNS server on Debian Linux.
summary: How to install Authoritative PowerDNS server on Debian Linux.
date: 2024-09-14T17:50:13+02:00
tags: ["PowerDNS", "DNS", "domain"]
keywords: ["PowerDNS", "DNS", "domain"]
# featureAlt:
thumbnailAlt: PowerDNS logo
coverAlt: Install Authoritative PowerDNS cover image
draft:  true
# aliases: ['/']
---

## Install `apt` Repository

```bash
echo "deb [signed-by=/etc/apt/keyrings/auth-49-pub.asc] http://repo.powerdns.com/debian $(lsb_release -c -s 2>/dev/null)-auth-49 main" | tee "/etc/apt/sources.list.d/pdns.list"
```

Pin the packages in `apt`:

```bash
echo -e "Package: auth*\nPin: origin repo.powerdns.com\nPin-Priority: 600" | tee /etc/apt/preferences.d/auth-49
```

Install the repository key:

```bash
install -d /etc/apt/keyrings
```

```bash
curl https://repo.powerdns.com/FD380FBB-pub.asc | tee /etc/apt/keyrings/auth-49-pub.asc
```

Update `apt`:

```bash
sudo apt-get update
```

## Install

```bash
apt-get install pdns-server
```