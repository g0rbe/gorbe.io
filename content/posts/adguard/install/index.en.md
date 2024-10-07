---
title: Install AdGuard Home
description: Install AdGuard Home on Debian Server
summary: Install AdGuard Home on Debian Server
date: 2024-10-05T13:49:38+02:00
tags: ["AdGuard", "dns", "dhcp", "privacy", "adblock", "dns-over-tls", "dns-over-https", "golang"]
keywords: ["AdGuard", "dns", "dhcp", "privacy", "adblock", "dns-over-tls", "dns-over-https", "golang"]
# featureAlt:
thumbnailAlt: AdGuard Logo
coverAlt: Install AdGuard Home Cover
draft:  false
# aliases: ['/']
---

## Requirements

```bash
sudo apt install gpg jq
```

### Static IP

```bash
sudo nano /etc/network/interfaces
```

```bash
allow-hotplug eth0
iface eth0 inet static
        address 192.168.1.2
        netmask 255.255.255.0
        gateway 192.168.1.1
```

```bash
sudo systemctl restart networking.service 
```

## Download binary

Download the latest binary release from the [release page](https://github.com/AdguardTeam/AdGuardHome/releases/):

```bash
wget "https://github.com/AdguardTeam/AdGuardHome/releases/download/$(wget -q -O- 'https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest' | jq -r '.tag_name')/AdGuardHome_linux_amd64.tar.gz"
```

### Unpack the tar archive

```bash
tar -xf AdGuardHome_linux_amd64.tar.gz
```

### Verify the binary


```bash
gpg --keyserver 'keys.openpgp.org' --recv-key '28645AC9776EC4C00BCE2AFC0FE641E7235E2EC6'
```

```bash
gpg --verify AdGuardHome/AdGuardHome.sig
```

## Install the binary

```bash
install AdGuardHome/AdGuardHome /usr/bin/adguard
```

## Create `adguard` group

```bash
sudo groupadd --system adguard
```

## Create `adguard` user

```bash
sudo useradd --system --gid="adguard" --create-home  --home-dir="/var/lib/adguard" --shell="/usr/sbin/nologin" adguard
```

## Config file

```bash
mkdir /etc/adguard
```

```bash
touch /etc/adguard/config.yaml
```

```bash
chown -R adguard:adguard /etc/adguard
```

## Configure systemd


```bash
sudo nano /etc/systemd/system/adguard.service
```

```systemd
[Unit]
Description=AdGuard Home: Network-level blocker
ConditionFileIsExecutable=/usr/bin/adguard
After=syslog.target network-online.target 

[Service]
User=adguard
Group=adguard
AmbientCapabilities=CAP_NET_BIND_SERVICE CAP_NET_RAW
StartLimitInterval=5
StartLimitBurst=10
ExecStart=/usr/bin/adguard --config "/etc/adguard/config.yaml" --work-dir "/var/lib/adguard"
WorkingDirectory=/var/lib/adguard
StandardOutput=journal
StandardError=journal
Restart=always
RestartSec=10
EnvironmentFile=-/etc/sysconfig/AdGuardHome

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
```

```bash
sudo systemctl enable --now adguard
```