---
title: "Create a database in MariaDB"
tags: ["mariadb", "mysql", "database"]
description: "Create a database in MariaDB."
---

## Install

```bash
sudo apt install mariadb-server
```

```bash
sudo mysql_secure_installation
```

## Create database and user

```bash
sudo mysql
```

```bash
create database my_database;
```

```bash
GRANT ALL PRIVILEGES ON my_database.* TO 'my_user'@'localhost' IDENTIFIED BY 'my_password' WITH GRANT OPTION;
```

```bash
flush privileges;
```
