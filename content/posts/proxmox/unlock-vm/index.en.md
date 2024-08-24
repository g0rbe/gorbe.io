---
title: "Unlock VM on Proxmox"
description: "How to Unlock a Locked VM on Proxmox"
summary: "How to Unlock a Locked VM on Proxmox"
date: 2024-01-31T03:33:09+01:00
tags: ["Proxmox", "QEMU", "virtualization", "virtual-machine"]
keywords: ["Proxmox", "QEMU", "virtualization", "virtual-machine"]
# featureAlt:
# draft:  true
aliases: ["/docs/proxmox/unlock-vm"]
---

Solve the `Error: VM is locked` error on Proxmox.

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
