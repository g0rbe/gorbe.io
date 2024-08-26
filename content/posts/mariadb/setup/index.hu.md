---
title: "Adatbázis létrehozása MariaDB-ben"
description: "Hogyan hozzunk létre adatbázist MariaDB-ben."
summary: "Hogyan hozzunk létre adatbázist MariaDB-ben."
tags: ["MariaDB", "MySQL", "database"]
keywords: ["MariaDB", "MySQL", "database"]
aliases: ["/hu/docs/mariadb/setup"]
---

## Telepítés

```bash
sudo apt install mariadb-server
```

```bash
sudo mysql_secure_installation
```

## Adatbázis és felhasználó létrehozása

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
