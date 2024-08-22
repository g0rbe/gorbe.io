---
title: "Simple Stateful Firewall with iptables"
description: "How to configure a simple Stateful Firewall with iptables."
summary: "How to configure a simple Stateful Firewall with iptables."
date: 2023-11-15T03:21:23+01:00
categories: ["iptables", "firewall", "security"]
keywords: ["iptables", "firewall", "security"]
---

::::info
iptables is replaced by [nftables](/docs/category/nftables) starting in Debian 10 (Buster)
::::

## Simple stateful firewall

In computing, a stateful firewall is a network firewall that tracks the operating state and characteristics of network connections traversing it. The firewall is configured to distinguish legitimate network packets for different types of connections. Only packets matching a known active connection are allowed to pass the firewall. In contrast a stateless firewall does not take context into account when determining whether to allow or block packets[1].

These rules are enough for a simple web server.

### IPv4

```bash
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
```

### IPv6

```bash
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p ipv6-icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -d fe80::/64 -p udp -m udp --dport 546 -m state --state NEW -j ACCEPT
-A INPUT -j REJECT --reject-with icmp6-adm-prohibited
-A FORWARD -j REJECT --reject-with icmp6-adm-prohibited
COMMIT
```

### Explanation

#### Default policies

`INPUT`

Drop everything, only accept incoming traffic to ports that we want. On LAN, it is suggested to gracefully REJECT packets instead of DROP.

`FORWARD`

On a typical server, we dont have any packets to forward, dont need it.

`OUTPUT`

Allow any output.

#### Rules

`-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT`

Allow related and established traffic. This mean that we initated the connection and the packet is the response.

`-A INPUT -p icmp -j ACCEPT`

Allow icmp protocol.

`-A INPUT -i lo -j ACCEPT`

Allow traffic on the loopback interface. This is essential for a proper work.

`-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT`

Allow new connections to my server's SSH, which is operates on TCP port 22 by default.

### Setup

Iptables is not persistent by default, rebooting your server will flush all iptables rules.
There is a package, called `iptables-persistent` to make it persistent.

```bash
sudo apt install iptables-persistent
```

This will want to save your existing rules.

To save again, use this command:

```bash
sudo dpkg-reconfigure iptables-persistent
```

or modify `/etc/iptables/rules.v{4,6}`.
