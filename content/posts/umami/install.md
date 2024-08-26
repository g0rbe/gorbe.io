---
sidebar_label: Install
title: Install umami on Linux
tags: [ "analytics", "web-analytics", "statistics"]
description: How to install Umami on Debian Linux server with PostgreSQL.
image: /assets/docs/umami/install/image-en.webp
---



## Requirements

- [Node.js](../nodejs/install.md) version 18.17 or newer
- MySQL version 8.0 or newer **OR** [PostgreSQL](../postgresql/setup.md) version v12.14 or newer 

:::warning

MariaDB is not supported because it doesn't implement the `BIN_TO_UUID` function.

:::

### Packages

```bash
apt install curl git postgresql-15
```

### Node.js

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt-get install -y nodejs
```

#### Yarn

Install Yarn:

```bash
npm install -g yarn
```

### PostgreSQL

Connect to PostgreSQL:

```bash
sudo -u postgres psql
```

Create the database:

```sql
CREATE DATABASE umami;
```

Create the user:

```sql
CREATE USER umami WITH ENCRYPTED PASSWORD 'UMAMI_DB_PASSWORD';
```


Set the permissions:

```sql
GRANT ALL PRIVILEGES ON DATABASE umami TO umami;
```

Change the database:

```sql
\c umami
```

Set the schema:

```sql
GRANT ALL ON SCHEMA public TO umami;
```

Exit from `psql`:

```sql
\q
```

## Create user and group

Create the group first:

```bash
groupadd --system umami
```

Create the `umami` user:

```bash
useradd --system --gid umami --create-home  --home-dir /var/umami --shell /usr/sbin/nologin umami
```

## Download

Clone the GitHub repository:

```bash
git clone https://github.com/umami-software/umami /opt/umami
```

Change the owner of the source:

```bash
chown -R umami:umami /opt/umami
```

Switch to `umami` user:

```bash
sudo -u umami /bin/bash
```

### Install the packages

```bash
cd /opt/umami
```

```bash
yarn install
```

## Configure

Create a `.env` file:

```bash
nano .env
```

Configure the DB connection:

```sh
DATABASE_URL="postgresql://umami:UMAMI_DB_PASSWORD@localhost:5432/umami"
DATABASE_TYPE="postgresql"
APP_SECRET="UMAMI_APP_SECRET"
```

Set permission for the file:

```bash
chmod 0640 .env
```

## Build

```bash
yarn build
```

:::info
The default username is `admin` and the password is `umami`
:::
## Configure systemd

Create the systemd service:

```bash
nano /etc/systemd/system/umami.service
```

```ini title="/etc/systemd/system/umami.service"
[Unit]
Description=Umami
After=postgresql@15-main.service
Requires=postgresql@15-main.service

[Service]
Type=exec
User=umami
Group=umami
WorkingDirectory=/opt/umami
ExecStart=yarn start

[Install]
WantedBy=multi-user.target
```

Reload systemd to load the new service:

```bash
systemctl daemon-reload
```

Enable the service to start at boot:

```bash
systemctl enable --now umami
```

