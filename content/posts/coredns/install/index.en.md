---
title: "Install CoreDNS from Binary on Debian 12"
description: "Install CoreDNS from Binary on Debian 12 server."
summary: "Install CoreDNS from Binary on Debian 12 server."
date: 2023-11-15T03:16:48+01:00
tags: ["coredns", "dns", "domain", "linux", "selfhost"]
keywords: ["coredns", "dns", "domain", "linux", "selfhost"]
draft:  false
aliases: ["/docs/coredns/install-from-binary"]
---

## Create user

Create a new user for CoreDNS to run as an unprivileged user. 
```bash
adduser --system --group --shell "/usr/sbin/nologin" --comment "CoreDNS" --home "/etc/coredns" coredns
```

## Install binary

1. Download the latest binary from the [releases](https://github.com/coredns/coredns/releases).
```bash
wget https://github.com/coredns/coredns/releases/download/v1.11.1/coredns_1.11.1_linux_arm64.tgz
```

```bash
wget https://github.com/coredns/coredns/releases/download/v1.11.1/coredns_1.11.1_linux_arm64.tgz.sha256
```

2. Check the SHA256 sum of the downloaded file.
```bash
sha256sum -c coredns_1.11.1_linux_arm64.tgz.sha256
```

3. Extract the the binary from the downloaded archive:
```bash
tar -xvf coredns_1.11.1_linux_arm64.tgz 
```

4. Install the binary:
```bash
install coredns /usr/bin/
```

## Corefile

1. Open `/etc/coredns/Corefile`:
```bash
nano /etc/coredns/Corefile
```

2. Write the lines below for a basic configuration:
```
. {
    forward . 1.1.1.1 8.8.8.8 9.9.9.9
    log
}
```

## systemd service

### `coredns.service`

```ini
[Unit]
Description=CoreDNS Server
Documentation=https://coredns.io/manual/
After=network-online.target
Wants=network-online.target

[Service]
User=coredns
Group=coredns
AmbientCapabilities=CAP_NET_BIND_SERVICE
Restart=always
WorkingDirectory=/etc/coredns
ExecStart=/usr/bin/coredns 
ExecReload=/usr/bin/kill -USR1 $MAINPID

[Install]
WantedBy=multi-user.target
```

### Create service

1. Open `/etc/systemd/system/coredns.service`:
```bash
nano /etc/systemd/system/coredns.service
```

2. Write the lines found under `coredns.service`.

### Start the service

1. Reload systemd
```bash
systemctl daemon-reload
```

2. Start `coredns.service`:
```bash
systemctl start coredns.service
```

### Enable CoreDNS

To start CoreDNS at system startup, enable it:
```bash
systemctl enable coredns.service
```

## Firewall

### nftables

Below is an example for [nftables](/tags/nftables):

```
#!/usr/sbin/nft -f

flush ruleset

table inet filter {

    chain inbound_ipv4 {
        icmp type echo-request limit rate 5/second accept
    }

    chain inbound_ipv6 {
        icmpv6 type { nd-neighbor-solicit, nd-router-advert, nd-neighbor-advert } accept
        icmpv6 type echo-request limit rate 5/second accept
    }

    chain input {
        type filter hook input priority 0; policy drop;
        ct state { established, related } accept
        iifname lo accept
        meta protocol vmap { ip : jump inbound_ipv4, ip6 : jump inbound_ipv6 }
        tcp dport 22 accept
        tcp dport 53 accept
        udp dport 53 accept
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0;
    }
}
```