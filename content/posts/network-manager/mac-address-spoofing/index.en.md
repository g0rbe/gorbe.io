---
title: "MAC Address Spoofing with Network Manager"
description: "How to Setup Network Manager to spoof MAC Address on Linux"
summary: "How to Setup Network Manager to spoof MAC Address on Linux"
date: 2024-08-21
tags: [ "NetworkManager", "linux","security", "privacy" ]
keywords: [ "NetworkManager", "linux","security", "privacy" ]
draft:  false
thumbnailAlt: Network Manager Logo
aliases: ["/docs/network-manager/mac-address-spoofing"]
---

Spoofing MAC address is possible with Network Manager since 1.4.0.
The device is sending probe requests while searching for known Wi-Fi.
This broadcast contains the SSID, the devices MAC address and the signal strength, thus the device [can be tracked][1].

Network Manager has setting for this, this setting is enabled by default:

```bash
wifi.scan-rand-mac-address=yes
```

When the device is connected to a network, the MAC address is restored to its original.

This configuration is responsible to change MAC at connection.

```bash
ethernet.cloned-mac-address=
wifi.cloned-mac-address=
```

The possible options:

- `permanent`: use the devices MAC
- `preserver`: dont change the devices MAC at activation
- `random`: random MAC at each connection
- `stable`: associate a MAC to a network, the MAC will be randomized for each network, means if you reconnect to those network, the MAC address will the same as before


To use these settings, create a new config file in `/etc/NetworkManager/conf.d`

```bash
nano /etc/NetworkManager/conf.d/10-mac.conf
```

Copy to the file:

```ini title="/etc/NetworkManager/conf.d/10-mac.conf"
[device-mac-randomization]
wifi.scan-rand-mac-address=yes

[connection-mac-randomization]
ethernet.cloned-mac-address=random
wifi.cloned-mac-address=random
```

Change `random` to another if you want.

Restart Network Manager:

```bash
systemctl restart NetworkManager
```

The fullpost can be found on [Thomas Haller's Blog][2]

[1]: https://www.freecodecamp.org/news/tracking-analyzing-over-200-000-peoples-every-step-at-mit-e736a507ddbf/
[2]: https://blogs.gnome.org/thaller/2016/08/26/mac-address-spoofing-in-networkmanager-1-4-0/
