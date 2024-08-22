---
title: "Install Node.js Binary Distribution"
tags: ['npm']
description: "Install the NodeSource Node.js Binary ditsribution via package manager on Linux."
---

## Requirements

### `curl`

Install `curl`:

```bash
apt install curl
```

## Node.js LTS version

<Tabs>
    <TabItem value="debian" label="Debian" default>
        ```bash
        curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - &&\
        apt-get install -y nodejs
        ```
    </TabItem>
    <TabItem value="ubuntu" label="Ubuntu">
        ```bash
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - &&\
        sudo apt-get install -y nodejs
        ```
  </TabItem>
</Tabs>

## Node.js `current` version

<Tabs>
    <TabItem value="debian" label="Debian" default>
        ```bash
        curl -fsSL https://deb.nodesource.com/setup_current.x | bash - &&\
        apt-get install -y nodejs
        ```
    </TabItem>
    <TabItem value="ubuntu" label="Ubuntu">
        ```bash
        curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash - &&\
        sudo apt-get install -y nodejs
        ```
  </TabItem>
</Tabs>


## Node.js v21.x

<Tabs>
    <TabItem value="debian" label="Debian" default>
        ```bash
        curl -fsSL https://deb.nodesource.com/setup_21.x | bash - &&\
        apt-get install -y nodejs
        ```
    </TabItem>
    <TabItem value="ubuntu" label="Ubuntu">
        ```bash
        curl -fsSL https://deb.nodesource.com/setup_21.x | sudo -E bash - &&\
        sudo apt-get install -y nodejs
        ```
  </TabItem>
</Tabs>

## Node.js v20.x

<Tabs>
    <TabItem value="debian" label="Debian" default>
        ```bash
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash - &&\
        apt-get install -y nodejs
        ```
    </TabItem>
    <TabItem value="ubuntu" label="Ubuntu">
        ```bash
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &&\
        sudo apt-get install -y nodejs
        ```
  </TabItem>
</Tabs>

## Node.js v18.x

<Tabs>
    <TabItem value="debian" label="Debian" default>
        ```bash
        curl -fsSL https://deb.nodesource.com/setup_18.x | bash - &&\
        apt-get install -y nodejs
        ```
    </TabItem>
    <TabItem value="ubuntu" label="Ubuntu">
        ```bash
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - &&\
        sudo apt-get install -y nodejs
        ```
  </TabItem>
</Tabs>
