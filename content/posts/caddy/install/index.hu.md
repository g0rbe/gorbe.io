---
title: Caddy Telepítése Linux Rendszeren
description:  Hogyan telepítsük a Caddy-t Debian Linux szerverre.
summary:  Hogyan telepítsük a Caddy-t Debian Linux szerverre.
date: 2024-08-15
tags: [ "web", "webserver", "HTTP", "caddy"]
keywords: [ "web", "webserver", "HTTP", "caddy"]
draft:  false
thumbnailAlt: "Caddy logo"
coverAlt: "cover-caddy-install-hu"
aliases: ["/hu/docs/caddy/install"]
---

## Bináris letöltése

Töltse le a legújabb bináris fájlt a `.tar.gz' archívumból a GitHub Releases oldaláról: [https://github.com/caddyserver/caddy/releases/latest](https://github.com/caddyserver/caddy/releases/latest)

```bash
wget https://github.com/caddyserver/caddy/releases/download/v2.7.6/caddy_2.7.6_linux_amd64.tar.gz
```

### Ellenőrző összeg ellenőrzése

```bash
wget https://github.com/caddyserver/caddy/releases/download/v2.7.6/caddy_2.7.6_checksums.txt
```

```bash
sha512sum --ignore-missing -c caddy_2.7.6_checksums.txt
```

### Aláírás ellenőrzése

Tekintse meg a [Caddy dokumentációját](https://caddyserver.com/docs/signature-verification), hogyan ellenőrizheti az aláírást.

## Bontsa ki a binárist

Bontsa ki a bináris fájlt a letöltött archívumból:

```bash
tar -xf caddy_2.7.6_linux_amd64.tar.gz caddy
```

## Telepítse a bináris fájlt

Az install paranccsal másolja a bináris fájlt a `/usr/local/bin/` mappába, és állítsa be az attribútumokat:

```bash
sudo install -v caddy /usr/bin/
```

## Felhasználó és csoport létrehozása

Először hozza létre a csoportot:

```bash
sudo groupadd --system caddy
```

A "caddy" felhasználó létrehozása:

```bash
sudo useradd --system --gid caddy --create-home --home-dir /var/lib/caddy --shell /usr/sbin/nologin caddy
```

## Hozzon létre Caddyfile-t

Hozza létre a Caddyfile könyvtárát:

```bash
mkdir /etc/caddy
```

Most hozza létre a Caddyfile-t:

```bash
touch /etc/caddy/Caddyfile
```

Módosítsa a konfigurációs könyvtár felhasználóját és csoportját:

```bash
chown -R caddy:caddy /etc/caddy/
```

## Systemd konfigurálása

Hozza létre a rendszeres szolgáltatást:

```bash
nano /etc/systemd/system/caddy.service
```

```ini title="/etc/systemd/system/caddy.service"
[Unit]
Description=Caddy
After=network.target network-online.target
Requires=network-online.target

[Service]
Type=notify
User=caddy
Group=caddy
ExecStartPre=/usr/bin/caddy validate --config /etc/caddy/Caddyfile
ExecStart=/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile --force
TimeoutStopSec=5s
LimitNOFILE=1048576
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
```

Töltse be újra a rendszert az új szolgáltatás betöltéséhez:

```bash
sudo systemctl daemon-reload
```

Engedélyezze a szolgáltatás indítását a rendszerindításkor:

```bash
sudo systemctl enable --now caddy
