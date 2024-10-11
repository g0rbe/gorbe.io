---
title: Install PowerDNS Recursor
description: How to install PowerDNS Recursor on Debian Linux.
summary: How to install PowerDNS Recursor on Debian Linux.
date: 2024-10-11T17:50:13+02:00
tags: ["PowerDNS", "DNS", "domain"]
keywords: ["PowerDNS", "DNS", "domain"]
# featureAlt:
thumbnailAlt: PowerDNS logo
coverAlt: Install PowerDNS Recursor cover image
draft:  true
# aliases: ['/']
---

## Install `apt` Repository

```bash
echo "deb [signed-by=/etc/apt/keyrings/rec-51-pub.asc] http://repo.powerdns.com/debian $(lsb_release -c -s 2>/dev/null)-rec-51 main" | tee "/etc/apt/sources.list.d/pdns.list"
```

Pin the packages in `apt`:

```bash
echo -e "Package: rec*\nPin: origin repo.powerdns.com\nPin-Priority: 600" | tee /etc/apt/preferences.d/rec-51
```

Install the repository key:

```bash
install -d /etc/apt/keyrings
```

```bash
wget -O- https://repo.powerdns.com/FD380FBB-pub.asc | tee /etc/apt/keyrings/rec-51-pub.asc
```

Update `apt`:

```bash
sudo apt-get update
```

## Install

```bash
apt-get install pdns-recursor
```