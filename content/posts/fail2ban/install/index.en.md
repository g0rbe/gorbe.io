---
title: "Install and Configure Fail2Ban for SSH on Debian"
description: "How to Install and Configure Fail2Ban for SSH on Debian"
summary:  "How to Install and Configure Fail2Ban for SSH on Debian"
date: 2023-11-15T10:57:40+01:00
tags: ["fail2ban", "security","hardening" ]
keywords: ["fail2ban", "security","hardening" ]
draft:  false
aliases: ["/docs/fail2ban/install"]
---

Fail2Ban is a vital security tool for Linux servers, particularly useful in protecting SSH services against brute-force attacks. It monitors service logs for malicious activity and bans offending IPs for a specified duration.

---

## Installing Fail2Ban

Fail2Ban is included in Debian’s default repositories, making it easy to install:

1. Update your package listings:
   ```bash
   sudo apt update
   ```

2. Install Fail2Ban:
   ```bash
   sudo apt install fail2ban
   ```

After installation, the Fail2Ban service starts automatically. Verify it with:

```bash
sudo systemctl status fail2ban
```

## Configuring Fail2Ban

Configuration involves editing `.local` files that override the default `.conf` files:

1. **Create a `.local` Configuration File**:
   Copy `jail.conf` to `jail.local`:
   ```bash
   sudo cp /etc/fail2ban/jail.{conf,local}
   ```

2. **Edit the `jail.local` File**:
   Open the file:
   ```bash
   sudo nano /etc/fail2ban/jail.local
   ```
   Here, you can set various parameters.

## Important Parameters

1. **Whitelisting IP Addresses**:
   Add trusted IPs to the `ignoreip` directive:
   ```bash
   ignoreip = 127.0.0.1/8 ::1 [Trusted IPs]
   ```

2. **Setting Ban Conditions**
   - `bantime`: Duration to ban the IP (default is 10 minutes).
   - `findtime`: Time window in which failures must occur.
   - `maxretry`: Number of failures before banning.

   Example settings:
   ```bash
   bantime = 1d
   findtime = 10m
   maxretry = 5
   ```

3. **Email Notifications**
   
   Configure to receive email alerts on banning events:

   ```bash
   action = %(action_mw)s
   destemail = your-email@example.com
   sender = server-email@example.com
   ```

## Configuring SSH Jail

Fail2Ban uses 'jails' for each service. For SSH, enable and configure the SSH jail in `jail.local`:

```ini
[sshd]
enabled = true
maxretry = 5
findtime = 12h
bantime = 1d
ignoreip = 127.0.0.1/8 [Other Trusted IPs]
```

## Restarting Fail2Ban

After changes, restart Fail2Ban to apply:

```bash
sudo systemctl restart fail2ban
```

## Using fail2ban-client

Manage Fail2Ban with `fail2ban-client`. Common commands include:

- Checking server status: `sudo fail2ban-client status`
- Unbanning an IP: `sudo fail2ban-client set sshd unbanip [IP Address]`

Explore more options with `fail2ban-client -h`.
