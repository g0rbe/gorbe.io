---
sidebar_label: Install Redmine 4
title: "How to Install Redmine 4 on Debian 10"
date: 2020-06-28T00:00:00+01:00
tags: ["linux", "redmine", "debian"]
description: "Install and configure Redmine 4 on Debian 10 with MariaDB, Nginx and Passenger."
---

## Install 

### Instal Requirements

#### Passenger

Passenger will be the the application server to run Ruby on Rails app.

``` bash
apt-get install -y dirmngr gnupg
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
apt-get install -y apt-transport-https ca-certificates
sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger buster main > /etc/apt/sources.list.d/passenger.list'
apt update
```


#### Packages

``` bash
apt install ruby-dev mariadb-server libmariadb-dev git imagemagick ghostscript build-essential patch zlib1g-dev liblzma-dev nginx libnginx-mod-http-passenger certbot python3-certbot-nginx -y
```

#### Redmine

Download Redmine from [here](https://www.redmine.org/projects/redmine/wiki/Download).

``` bash
wget https://www.redmine.org/releases/redmine-4.1.1.tar.gz
```

Check the checksum:

``` bash
sha256sum redmine-4.1.1.tar.gz
```

Extract the tar file:

``` bash
tar -xf redmine-4.1.1.tar.gz -C /var/www
```

Create a link for easier version management:

``` bash
ln -s /var/www/redmine-4.1.1/ /var/www/redmine
```

### Configure MariaDB


Initialize MariaDB:

``` bash
mysql_secure_installation
```

Create the database for Redmine:

``` bash
mysql -u root -p
```

``` sql
create database [REDMINEDB] character set utf8mb4;
grant all on [REDMINEDB].* to [REDMINEUSER]@localhost identified by 'S3cur3P4ssw0rd';
flush privileges;
quit;
```

### Configure Redmine

``` bash
cd /var/www/redmine/
cp config/database.yml.example config/database.yml
nano config/database.yml
```

``` yml
production:
  adapter: mysql2
  database: [REDMINEDB]
  host: localhost
  username: [REDMINEUSER]
  password: "S3cur3P4ssw0rd"
  encoding: utf8mb4
```

``` bash
gem install bundler
bundle install --without development test
```

``` bash
bundle exec rake generate_secret_token
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake redmine:load_default_data
```

``` bash
chown -R www-data:www-data /var/www/redmine/
```

Because of [Passenger's sandboxing system](https://www.phusionpassenger.com/library/deploy/apache/user_sandboxing.html), Redmine will be running as `www-data`.

Verify it later with `ps`:

``` bash
ps aux | grep redmine
```

``` bash
...
www-data 19895  0.0  8.7 484136 173532 ?       Sl   Jun20   0:06 Passenger AppPreloader: /var/www/redmine (forking...)
```


### Get a certificate from Let's Encrypt

```
certbot certonly --nginx -d example.com --rsa-key-size 4096
```

### Configure Nginx

A basic Nginx config:

``` nginx
# https
server {

        listen [::]:443 ssl http2;
        listen 443 ssl http2;

        ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

        root /var/www/redmine/public;
        server_name example.com;

        passenger_enabled on;
        passenger_ruby /usr/bin/ruby;
        passenger_sticky_sessions on;
}

# redirect http to https
server {

        listen 80;
        listen [::]:80;
        server_name  example.com;
 
        return 301 https://$host$request_uri;
}
```

Append `passenger_show_version_in_header off;` to the `http` context to hide Passenger version number.

## Configure

### SMTP

To use your own SMTP server edit `configuration.yml`:

``` bash
nano /var/www/redmine/config/configuration.yml
```


``` yml
  email_delivery:
    delivery_method: :smtp
    smtp_settings:
      address: smtp.example.com
      port: 587
      domain: example.com
      enable_starttls_auto: true
      authentication: :login
      user_name: redmine@example.com
      password: SmtpP4ssw0rd
```

### Attachment storage path

For the easier version management, store the attachments outside of the web root.
I made a directory in `/etc`:

``` bash
mkdir -p /etc/redmine/storage
chown -R www-data:www-data /etc/redmine
```

Modify `configuration.yml`:

``` bash
nano /var/www/redmine/config/configuration.yml
```


``` yml
  attachments_storage_path: /etc/redmine/storage
```
