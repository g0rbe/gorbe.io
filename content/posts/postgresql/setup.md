---
title: 'Setup PostgreSQL'
tags: ["sql", "database"]
description: 'How to setup PostgreSQL database'
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

:::info
Change the database before configuring the schema:

```bash
\c <db>
```

:::

```sql
GRANT ALL ON SCHEMA public TO user;
```