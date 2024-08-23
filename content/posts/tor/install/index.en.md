---
title: Install Tor
description: How to install Tor on Debian
summary: How to install Tor on Debian
date: 2024-08-22T03:42:59+02:00
tags: ["tor", "security"]
keywords: ["tor", "security"]
draft:  true
---

## Requirements

```bash
apt install apt-transport-https
```

## APT Source

```bash
echo "deb [signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org $(lsb_release -c -s 2>/dev/null) main" > /etc/apt/sources.list.d/tor.list
```

```bash
echo "deb-src [signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org $(lsb_release -c -s 2>/dev/null) main" >> /etc/apt/sources.list.d/tor.list
```

### Signing Key

```bash
wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null
```

## Install

```bash
apt update && apt install tor deb.torproject.org-keyring
```