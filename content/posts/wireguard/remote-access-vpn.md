---
title: Setup a Remote Access VPN with WireGuard
tags: ["wireguard", "vpn"]
description: "Setup a Remote Access VPN with WireGuard and nftables on Debain 12"
---

## Server

Create WireGuard server.

### Setup

Set temporary permission for new files:
```bash
umask 077
```

Create the keys:
```bash
wg genkey | tee /etc/wireguard/privkey
```

```bash
wg pubkey < /etc/wireguard/privkey | tee /etc/wireguard/pubkey
```

Create the config file:
```bash
nano /etc/wireguard/wg0.conf
```

```ini
[Interface]
Address = 10.10.10.1/24
ListenPort = 51820
SaveConfig = True
PrivateKey = ...
```

Start:
```bash
wg-quick up wg0
```

Enable:
```bash
systemctl enable wg-quick@wg0
```

### Add peer

:::caution
Stop WireGuard before editing `wg0.conf`!
:::

Append to `wg0.conf`:
```bash
nano /etc/wireguard/wg0.conf
```
```
[Peer]
AllowedIPs = 10.10.10.2/32
PublicKey = ...
PresharedKey = ...
```

## Client

Configure WireGuard client.

Set temporary permission for new files:
```bash
umask 077
```

Create the keys:
```bash
wg genkey | tee /etc/wireguard/privkey
```

```bash
wg pubkey < /etc/wireguard/privkey | tee /etc/wireguard/pubkey
```

```bash
wg genpsk | tee /etc/wireguard/psk
```

Create the config file:
```bash
nano /etc/wireguard/wg0.conf
```

```ini
[Interface]
Address = 10.10.10.2/32
PrivateKey = ...

[Peer]
Endpoint = X.X.X.X:51820
AllowedIPs = 10.10.10.0/24
PublicKey = ...
PreSharedKey = ...
PersistentKeepalive = 20
```

## Gateway

Use WireGuard server as gateway.

### nftable

```
define WAN_IF   = eth0
define WG_NET   = 10.10.10.0/24
define WG_IF    = wg0

table nat {

        chain prerouting {
                type nat hook prerouting priority -100; policy accept;
                #tcp dport 8080 iif $WAN_IF dnat to 10.10.10.2:8080
        }

        chain postrouting {
                type nat hook postrouting priority 100; policy accept;
                ip saddr $WG_NET oif $WAN_IF masquerade
        }
}

table inet filter {

        chain input_wan {
                tcp dport 22 accept
                udp dport 51820 accept
                icmp type echo-request limit rate 5/second accept
                icmpv6 type { nd-neighbor-solicit, nd-router-advert, nd-neighbor-advert } accept
                icmpv6 type echo-request limit rate 5/second accept
        }

        chain input_wg {
                accept
        }

        chain input {
                type filter hook input priority 0; policy drop;
                ct state vmap { established : accept, related : accept, invalid : drop }
                iifname vmap { lo : accept, $WAN_IF : jump input_wan, $WG_IF : jump input_wg }
                reject
        }

        chain forward {
                type filter hook forward priority 0; policy drop;
                ct state vmap { established : accept, related : accept, invalid : drop }
                iif $WG_IF oif $WAN_IF accept
                iif $WAN_IF oif $WG_IF accept
				iif $WG_IF oif $WG_IF accept

        }

        chain output {
                type filter hook output priority 0;
        }
}
```

### Forwarding

Enable IP forwarding:
```bash
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
```

```bash
echo "net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf
```

```bash
sysctl -p
```
