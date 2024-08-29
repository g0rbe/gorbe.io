---
title: 'Setup PostgreSQL'
description: 'How to setup PostgreSQL and create a database'
summary: 'How to setup PostgreSQL and create a database'
date: 2024-04-24
tags: ["PostgreSQL", "SQL", "database"]
keywords: ["PostgreSQL", "SQL", "database"]
---

## Connect

```bash
sudo -u postgres psql
```

## Create DB

```sql
CREATE DATABASE name;
```

## Create user

```sql
CREATE USER user WITH ENCRYPTED PASSWORD 'password';
```

```sql
GRANT ALL PRIVILEGES ON DATABASE name TO user;
```

{{< alert "circle-info" >}}
Change the database before configuring the schema:

```bash
\c <db>
```
{{< /alert >}}

```sql
GRANT ALL ON SCHEMA public TO user;
```