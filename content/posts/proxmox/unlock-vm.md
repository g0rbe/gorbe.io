---
sidebar_label: Unlock VM
title: "Unlock VM on Proxmox"
tags: ["Proxmox", "QEMU", "virtualization", "virtual-machine"]
description: "How to Unlock a Locked VM on Proxmox"
aliases: ["/docs/proxmox/unlock-vm"]
---



## Error

- `Error: VM is locked`
- `Error: VM is locked (backup)`
- `Error: VM is locked (snapshot)`
- `Error: VM is locked (clone)`

## Solutions

```bash
qm unlock <vmid>
```

```bash
kill -9 $(pgrep -f "/usr/bin/kvm -id <vmid>")
```
