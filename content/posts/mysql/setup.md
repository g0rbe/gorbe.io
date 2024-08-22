---
title: 'Setup a New Database and User in MySQL'
categories: ["MySQL", "database"]
description: 'How to Create a New Database and User in MySQL'
---

```bash
sudo mysql
```

```bash
create database my_database;
```

```sql
CREATE USER 'user'@'localhost' IDENTIFIED BY 'PASSWORD';
```

```sql
GRANT ALL PRIVILEGES ON db.* TO 'user'@'localhost';
```

```bash
flush privileges;
```
