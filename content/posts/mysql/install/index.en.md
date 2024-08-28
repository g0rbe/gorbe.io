---
title: 'Install MySQL Community Server on Linux Server'
tags: ["MySQL"]
description: 'How to Install MySQL Community Server on Linux Server.'

aliases: ["/docs/mysql/install"]
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

{{< alert "circle-info" >}}
MySQL was replaced by [Mariadb](../../mariadb/setup/index.en.md) in Debian 9 (Stretch).
{{< /alert >}}

## Repository Setup

Download and install the Repository Setup Package:

<Tabs>
  <TabItem value="apt" label="APT" default>
    https://dev.mysql.com/downloads/repo/apt/
  </TabItem>
  <TabItem value="yum" label="Yum">
    https://dev.mysql.com/downloads/repo/yum/
  </TabItem>
  <TabItem value="suse" label="SUSE">
    https://dev.mysql.com/downloads/repo/suse/
  </TabItem>
</Tabs>

Download the `deb` package for Debian based distros:

```bash
wget https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb
```

```bash
apt install ./mysql-apt-config_0.8.29-1_all.deb
```

## Configure Repository

![MySQL Configure](configure.webp)

## Install

```bash
apt install mysql-community-server
```