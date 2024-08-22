---
title: Install MinIO on Linux
categories: [ "s3", "storage"]
description: How to install MinIO binary on Debian Linux server.
#image: /assets/docs/umami/install/image-en.webp
---

import PasswordCodeBlock from '../../src/components/PasswordCodeBlock';
import CodeBlock from '@theme/CodeBlock';

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

# MinIO RELEASE.2023-05-04T21-44-30Z adds support for Type=notify (https://www.freedesktop.org/software/systemd/man/systemd.service.html#Type=)
# This may improve systemctl setups where other services use `After=minio.server`
# Uncomment the line to enable the functionality
# Type=notify

# Let systemd restart this service always
Restart=always

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536

# Specifies the maximum number of threads this process can create
TasksMax=infinity

# Disable timeout logic and wait until process is stopped
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