---
sidebar_label: Install
title: Install MongoDB Community Edition
tags: [ "db", "nosql"]
description: How to install MongoDB Community Edition on Debian Linux server using the apt package manager.
#image: /assets/docs/caddy/install/image-en.webp
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

## Requirements

```bash
sudo apt-get install gnupg curl
```

## Configure `apt`

Import MongoDB publis GPG key:

```bash
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
```

Create `apt` list:

<Tabs>
  <TabItem value="bookworm" label="Debian 12" default>
    ```bash
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] http://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    ```
  </TabItem>
  <TabItem value="bullseye" label="Debian 11">
    ```bash
    echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/7.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    ```
  </TabItem>
</Tabs>

Update `apt` package database:

```bash
apt update
```

Install the latest version:

```bash
apt install -y mongodb-org
```