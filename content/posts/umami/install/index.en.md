---
title: Install umami
description: How to install Umami on Debian Linux server with PostgreSQL.
summary: How to install Umami on Debian Linux server with PostgreSQL.
date: 2024-05-04
tags: [ "umami", "analytics", "statistics"]
keywords: [ "umami", "analytics", "statistics"]
coverAlt: "Install umami"
thumbnailAlt: umami Logo
aliases: ["/docs/umami/install"]
---

## Requirements

- [Node.js](../../nodejs/install/) version 18.17 or newer
- MySQL version 8.0 or newer **OR** [PostgreSQL](../../postgresql/setup/) version v12.14 or newer 

{{< alert >}}
MariaDB is not supported because it doesn't implement the `BIN_TO_UUID` function.
{{< /alert >}}

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

{{< alert >}}
The default username is `admin` and the password is `umami`
{{< /alert >}}

## Configure systemd

Create the systemd service:

```bash
nano "/etc/systemd/system/umami.service"
```

```ini
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

