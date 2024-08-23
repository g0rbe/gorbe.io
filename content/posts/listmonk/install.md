---
title: Install listmonk on Debian
tags: [ "smtp", "email"]
description: How to install listmonk binary on Debian Linux server.
#image: /assets/docs/umami/install/image-en.webp
---

import PasswordCodeBlock from '../../src/components/PasswordCodeBlock';
import CodeBlock from '@theme/CodeBlock';

## User and group

Create the user and the group for `listmonk`:

```bash
adduser --system --group --shell="/sbin/nologin" --home="/var/lib/listmonk" listmonk
```

## PostgreSQL

Install [Postgre](../postgresql/setup.md):

```bash
apt install postgresql
```

Setup the DB:

```bash
sudo -u postgres psql
```

```sql
CREATE DATABASE listmonk;
```

<PasswordCodeBlock  language="sql" numSymbols={0} tokens={[ {name: "SECURE_PASSWORD"}]} >
{`CREATE USER listmonk WITH ENCRYPTED PASSWORD 'SECURE_PASSWORD';`}
</PasswordCodeBlock>

```sql
GRANT ALL PRIVILEGES ON DATABASE listmonk TO listmonk;
```

## Binary

Download the latest binary from [Github](https://github.com/knadh/listmonk/releases/latest):

```bash
wget 'https://github.com/knadh/listmonk/releases/download/v3.0.0/listmonk_3.0.0_checksums.txt'
```

```bash
wget 'https://github.com/knadh/listmonk/releases/download/v3.0.0/listmonk_3.0.0_linux_amd64.tar.gz'
```

Check the checksum:

```bash
sha256sum -c listmonk_3.0.0_checksums.txt
```

Extract the binary from the downloaded archive:

```bash
tar -xvf listmonk_3.0.0_linux_amd64.tar.gz
```

Install the binary:

```bash
sudo install -v listmonk /usr/local/bin/
```

## Config

Create a directory to store the config file:

```bash
mkdir /etc/listmonk
```

```bash
listmonk --new-config
```

```bash
listmonk --install
```

Move the config file and fill in the credentials:

```bash
mv config.toml /etc/listmonk/
```

```bash
chown -R listmonk:listmonk /etc/listmonk/
```


## Systemd

Create the service:

```bash
nano /usr/lib/systemd/system/listmonk.service
```

```Systemd
[Unit]
Description=listmonk
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/listmonk

[Service]
User=listmonk
Group=listmonk

Restart=always
RestartSec=10

ExecStart=listmonk --config /etc/listmonk/config.toml

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload
```

```bash
systemctl enable --now listmonk.service
```