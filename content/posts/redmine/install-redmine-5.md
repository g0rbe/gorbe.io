---
sidebar_label: Install Redmine 5
title: "How to Install Redmine 5 on Debian 12"
date: 2024-02-06T04:05:06+01:00
tags: ["projectmanagement", "productivity", "selfhost", "opensource"]
description: "How to Install Redmine 5.1 on Debian 12"
---

Redmine is a flexible project management web application. Written using the Ruby on Rails framework, it is cross-platform and cross-database.
Redmine is open source and released under the terms of the [GNU General Public License v2](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html) (GPL).

## Install requirements

```bash
sudo apt install postgresql ruby ruby-dev build-essential libpq-dev imagemagick ghostscript
```

## Download Redmine

```bash
cd /opt/
```

```bash
wget https://www.redmine.org/releases/redmine-5.1.1.tar.gz
```

Check the SHA256SUM of the downloaded archive:

```bash
sha256sum redmine-5.1.1.tar.gz 
```

Extract the archive:

```bash
tar -xf redmine-5.1.1.tar.gz
```

```bash
ln -s /opt/redmine-5.1.1 /opt/redmine
```

## Create an empty database and the user

```bash
sudo -u postgres psql
```

```postgresql
CREATE ROLE redmine LOGIN ENCRYPTED PASSWORD 'my_password' NOINHERIT VALID UNTIL 'infinity';
CREATE DATABASE redmine WITH ENCODING='UTF8' OWNER=redmine;
\c redmine
GRANT ALL ON SCHEMA public TO redmine;
```

## Database configuration

Copy `config/database.yml.example` to `config/database.yml` and edit this file in order to configure your database settings for "production" environment.

```bash
cp config/database.yml.example config/database.yml
```

```bash
nano config/database.yml
```

```yaml
production:
  adapter: postgresql
  database: redmine
  host: localhost
  username: redmine
  password: "<postgres_user_password>" 
  encoding: utf8
```

## Install Ruby dependencies

### `Puma`

Add `Puma` gem:

```bash
nano Gemfile.local
```

```ruby
# Gemfile.local
gem 'puma'
```


```bash
bundle3.1 config set --local without 'development test' 
```

```bash
bundle3.1 install
```

## Session token generation

```bash
bundle3.1 exec rake generate_secret_token
```

## Database schema objects creation

```bash
RAILS_ENV=production bundle3.1 exec rake db:migrate
```

## Database default data set

```bash
RAILS_ENV=production bundle3.1 exec rake redmine:load_default_data
```

## Filesystem permissions

Add `redmine` user:

```bash
adduser --system --group --no-create-home --shell /sbin/nologin redmine
```

```bash
chown -R redmine:redmine  /opt/redmine
```

## Configurations

Redmine settings are defined in a file named `config/configuration.yml`.
If you need to override default application settings, simply copy `config/configuration.yml.example` to `config/configuration.yml`. 

## Start the server

```bash
bundle3.1 exec rails server -e production
```

### systemd

```bash
nano /lib/systemd/system/redmine.service
```

```systemd
[Unit]
Description=Redmine
After=postgresql.service

[Service]
User=redmine
Group=redmine
WorkingDirectory=/opt/redmine/
Type=simple
Restart=always
RestartSec=1
ExecStart=/usr/bin/bundle3.1 exec rails server -e production

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload
```

```bash
systemctl enable --now redmine.service
```
