---
title: "Install Node.js Binary Distribution"
description: "Install the NodeSource Node.js Binary ditsribution via package manager on Linux."
summary: "Install the NodeSource Node.js Binary ditsribution via package manager on Linux."
tags: ["NodeJS", 'npm']
keywords: ["NodeJS", 'npm']
aliases: ["/docs/nodejs/install"]
---

## Requirements

### `curl`

Install `curl`:

```bash
apt install curl
```

## `LTS` version

### Debian

```bash
curl -fsSL "https://deb.nodesource.com/setup_lts.x" | bash - &&\
apt-get install -y nodejs
```

### Ubuntu

```bash
curl -fsSL "https://deb.nodesource.com/setup_lts.x" | sudo -E bash - &&\
sudo apt-get install -y nodejs
```

## `current` version

### Debian

```bash
curl -fsSL "https://deb.nodesource.com/setup_current.x" | bash - &&\
apt-get install -y nodejs
```

### Ubuntu

```bash
curl -fsSL "https://deb.nodesource.com/setup_current.x" | sudo -E bash - &&\
sudo apt-get install -y nodejs
```

## `v21.x` version

### Debian

```bash
curl -fsSL "https://deb.nodesource.com/setup_21.x" | bash - &&\
apt-get install -y nodejs
```

### Ubuntu

```bash
curl -fsSL "https://deb.nodesource.com/setup_21.x" | sudo -E bash - &&\
sudo apt-get install -y nodejs
```

## `v20.x` version

### Debian

```bash
curl -fsSL "https://deb.nodesource.com/setup_20.x" | bash - &&\
apt-get install -y nodejs
```

### Ubuntu

```bash
curl -fsSL "https://deb.nodesource.com/setup_20.x" | sudo -E bash - &&\
sudo apt-get install -y nodejs
```

## `v18.x` version

### Debian

```bash
curl -fsSL "https://deb.nodesource.com/setup_18.x" | bash - &&\
apt-get install -y nodejs
```

### Ubuntu

```bash
curl -fsSL "https://deb.nodesource.com/setup_18.x" | sudo -E bash - &&\
sudo apt-get install -y nodejs
```