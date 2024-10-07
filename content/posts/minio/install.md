---
title: Install MinIO on Linux
description: How to install MinIO binary on Debian Linux server.
summary: How to install MinIO binary on Debian Linux server.
date: 2024-08-28
tags: [ "Minio", "S3", "storage", "objectstorage"]
keywords: [ "Minio", "S3", "storage", "objectstorage"]
# featureAlt:
# thumbnailAlt:
# coverAlt:
# draft:  true
aliases: ['/docs/minio/install']
---

## User and group

Create the user and the group for `Minio`:

```bash
adduser --system --group --shell="/sbin/nologin" --home="/var/lib/minio" minio
```

```bash
chown -R minio:minio /mnt/data
```

## Binary

```bash
wget https://dl.min.io/server/minio/release/linux-amd64/minio
```

```bash
sudo install -v minio /usr/local/bin/
```

## Config

```bash
nano /etc/default/minio
```

<PasswordCodeBlock  language="sql" numSymbols={0} tokens={[ {name: "SECURE_PASSWORD"}]} >
{`MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD="SECURE_PASSWORD"

MINIO_VOLUMES="/mnt/data"

MINIO_OPTS='--console-address=:9001 --sftp=\"address=:9022\" --sftp=\"ssh-private-key=/var/lib/minio/.ssh/id_rsa\"'`}
</PasswordCodeBlock>

### SFTP

Create the directory for the key:

```bash
sudo -u minio mkdir /var/lib/minio/.ssh
```

Create an RSA4096 key:

```bash
sudo -u minio ssh-keygen -b 4096 -f /var/lib/minio/.ssh/id_rsa -N "" -t rsa
```

## Systemd

Create the service:

```bash
nano /usr/lib/systemd/system/minio.service
```

```Systemd
[Unit]
Description=MinIO
Documentation=https://min.io/docs/minio/linux/index.html
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio

[Service]
WorkingDirectory=/var/lib/minio

User=minio     
Group=minio     
ProtectProc=invisible

EnvironmentFile=-/etc/default/minio
ExecStartPre=/bin/bash -c "if [ -z \"${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"
ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES

Type=notify

Restart=always

LimitNOFILE=65536

TasksMax=infinity

TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload
```

```bash
systemctl enable --now minio.service
```