---
title: 'Upgrade Debian release'
description: 'A guide about how to upgrade to the Debian release'
summary: 'A guide about how to upgrade to the Debian release'
date: 2023-08-15T08:27:34+01:00
tags: ["debian", "linux"]
keywords: ["debian", "linux"]
draft:  false
---

## Upgrade 11 to 12

### Prerequisites

1. **Superuser Privileges**: You must perform the upgrade with superuser privileges. Log in as root or a user with sudo privileges.
2. **Data Backup**: Back up your data before starting the upgrade. If you're using a virtual machine, consider taking a complete system snapshot.

### Update All Currently Installed Packages

Ensure your Debian 11 system is fully updated before the upgrade. Use the following APT commands and then reboot the system.

```bash
sudo apt update
sudo apt upgrade
sudo apt full-upgrade
sudo apt --purge autoremove
sudo reboot
```

### Check for Installed Non-Debian Packages

Inspect your system for non-Debian packages, as they might cause complications during the upgrade. You might need to uninstall non-critical software installed from external repositories.

```bash
sudo apt list '?narrow(?installed, ?not(?origin(Debian)))'
```

### Update Software Sources Files

Reconfigure your APT sources to point to the Debian 12 repositories. Backup current sources first, then update them to target 'Bookworm'.

```bash
mkdir ~/apt
cp /etc/apt/sources.list ~/apt
cp -r /etc/apt/sources.list.d/ ~/apt
sudo sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list
sudo sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/*
```


#### `non-free-firmware`

For Debian 12 onwards, all the packaged non-free firmware binaries that Debian can distribute have been moved to a new component in the Debian archive, called **non-free-firmware**.

```bash
deb http://deb.debian.org/debian/ bookworm main  non-free-firmware
```

### Upgrade to Debian 12 “Bookworm” from Debian 11 “Bullseye”

Proceed with the full system upgrade using the `apt full-upgrade` command. Keep an eye on the screen for notifications and prompts during the process, and reboot the system once completed.

```bash
sudo apt full-upgrade
sudo reboot
```

### Cleaning up Obsolete Packages

After upgrading, remove obsolete packages from your Debian 12 system using the following command.

```bash
sudo apt --purge autoremove
```

## Upgrade 10 to 11

### Prerequisites

1. **Superuser Privileges**: You must perform the upgrade with superuser privileges. Log in as root or a user with sudo privileges.
2. **Data Backup**: Back up your data before starting the upgrade. If you're using a virtual machine, consider taking a complete system snapshot.

### Update Current Packages

1. **Check for Held Back Packages**: Run `sudo apt-mark showhold` to check for any packages that are held back, as they can cause issues during the upgrade. Unhold them if necessary.
2. **Update Installed Packages**: Refresh your package index and upgrade all installed packages using the following commands:
   ```bash
   sudo apt update
   sudo apt upgrade
   ```
3. **Perform a Full Upgrade**: Use `sudo apt full-upgrade` to update your packages to the latest versions. This command may also remove unnecessary packages.
4. **Clean Up**: After the full upgrade, remove any automatically installed dependencies that are no longer needed with `sudo apt autoremove`.

### Modify APT’s Source-List Files

1. **Reconfigure APT Sources**: Open `/etc/apt/sources.list` and replace each occurrence of `buster` with `bullseye`. If you have other source files under `/etc/apt/sources.list.d`, update those as well.
2. **Using sed Command**: Alternatively, execute the following `sed` commands to update your sources list:
   ```bash
   sudo sed -i 's/buster/bullseye/g' /etc/apt/sources.list
   sudo sed -i 's/buster/bullseye/g' /etc/apt/sources.list.d/*.list
   sudo sed -i 's#/debian-security bullseye/updates# bullseye-security#g' /etc/apt/sources.list
   ```
   ```shell
   deb http://deb.debian.org/debian bullseye main contrib non-free
   deb http://deb.debian.org/debian bullseye-updates main contrib non-free
   deb http://deb.debian.org/debian-security bullseye-security/updates main
   ```
3. **Set Terminal Output to English**: This helps to avoid language-specific issues during the upgrade. Use `export LC_ALL=C` to set the language to English.
4. **Update Packages Index Again**: Run `sudo apt update` to refresh the package index with the new sources.


### Perform the System Upgrade

1. **Upgrade Installed Packages**: Begin the system upgrade with `sudo apt upgrade`. This step upgrades packages without requiring additional packages to be installed or removed.
2. **Full System Upgrade**: Execute `sudo apt full-upgrade` to perform a complete system upgrade. This command resolves dependency changes and upgrades packages that were not updated in the previous step.
3. **Clean Up and Reboot**: After completing the full upgrade, clean up unnecessary packages again with `sudo apt autoremove`. Then, reboot your machine to activate the new kernel using `sudo systemctl reboot`.

### Confirm the Upgrade

After rebooting, confirm that your system has been successfully upgraded to Debian 11 (Bullseye) by running `lsb_release -a`. The output should indicate Debian GNU/Linux 11 (Bullseye) as the distribution.