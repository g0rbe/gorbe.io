---
title: "A Redmine 5 telepítése"
date: 2024-02-06T04:05:06+01:00
description: A Redmine 5 telepítése Debian 12 rendszeren.
summary: A Redmine 5 telepítése Debian 12 rendszeren.
tags: ["projectmanagement", "productivity", "opensource"]
keywords: ["projectmanagement", "productivity", "opensource"]
aliases: ["/hu/docs/redmine/how-to-install-redmine-5.1-on-debian-12/"]
thumbnailAlt: Redmine Logo
---

A Redmine egy rugalmas projektmenedzsment webalkalmazás. A Ruby on Rails keretrendszerrel írva platformok és adatbázisok közötti.
A Redmine nyílt forráskódú, és a [GNU General Public License v2](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html) (GPL) feltételei szerint adják ki.

## Telepítési követelmények

```bash
sudo apt install postgresql ruby ruby-dev build-essential libpq-dev imagemagick ghostscript
```

## Töltse le a Redmine-t

```bash
cd /opt/
```

```bash
wget https://www.redmine.org/releases/redmine-5.1.1.tar.gz
```

Ellenőrizze a letöltött archívum SHA256SUM értékét:

```bash
sha256sum redmine-5.1.1.tar.gz
```

Az archívum kibontása:

```bash
tar -xf redmine-5.1.1.tar.gz
```

```bash
ln -s /opt/redmine-5.1.1 /opt/redmine
```

## Hozzon létre egy üres adatbázist és a felhasználót

```bash
sudo -u postgres psql
```

```postgresql
CREATE ROLE redmine LOGIN ENCRYPTED PASSWORD 'my_password' NOINHERIT VALID UNTIL 'infinity';
CREATE DATABASE redmine WITH ENCODING='UTF8' OWNER=redmine;
\c redmine
GRANT ALL ON SCHEMA public TO redmine;
```

## Adatbázis konfiguráció

Másolja a "config/database.yml.example" fájlt a "config/database.yml" fájlba, és szerkessze ezt a fájlt, hogy konfigurálja az adatbázis-beállításokat a "termelési" környezethez.

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

## Telepítse a Ruby-függőségeket

### `Puma`

Add hozzá a "Puma" gyöngyszemet:

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

## Munkamenet token generálása

```bash
bundle3.1 exec rake generate_secret_token
```

## Adatbázisséma objektumok létrehozása

```bash
RAILS_ENV=production bundle3.1 exec rake db:migrate
```

## Adatbázis alapértelmezett adatkészlete

```bash
RAILS_ENV=production bundle3.1 exec rake redmine:load_default_data
```

## Fájlrendszer-engedélyek

Redmine felhasználó hozzáadása:

```bash
adduser --system --group --no-create-home --shell /sbin/nologin redmine
```

```bash
chown -R redmine:redmine /opt/redmine
```

## Konfigurációk

A Redmine beállításai a `config/configuration.yml` nevű fájlban vannak meghatározva.
Ha felül kell bírálnia az alkalmazás alapértelmezett beállításait, egyszerűen másolja a `config/configuration.yml.example` fájlt a `config/configuration.yml` fájlba.

## Indítsa el a szervert

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