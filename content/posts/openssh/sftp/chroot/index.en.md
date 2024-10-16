---
title: "Configure SFTP with Chroot Jail"
description: "Guide to configure SFTP with Chroot Jail with OpenSSH on Debian"
summary: "Guide to configure SFTP with Chroot Jail with OpenSSH on Debian"
date: 2023-11-15T12:32:06+01:00
tags: ["linux", "security", "SSH", "SFTP"]
keywords: ["linux", "security", "SSH", "SFTP"]
# featureAlt:
# draft:  true
aliases: ["/docs/openssh/sftp-chroot", "/posts/openssh/sftp-chroot"]
---

Setting up a chroot jail for SFTP (Secure File Transfer Protocol) on a Debian server enhances security by restricting users' access to a specific directory. This is particularly useful for granting limited file transfer capabilities without providing full shell access.

## Requirements

### `openssh-server`

Ensure that the SSH server is installed:

```sh
apt install openssh-server
```

## Creating User and Group

Create a group for chroot-restricted users:

```sh
groupadd sftponly
```

Add a user to this group and set their home directory:

```bash
useradd -m -g sftponly -s /bin/false username
```

```sh
passwd username
```

Ensure the user's home directory is owned by root:

```bash
chown root:root /home/username
```

Create a subdirectory for user files, with appropriate permissions:

```bash
mkdir /home/username/files
```

```sh
chown username:sftponly /home/username/files
```

## Installing and Configuring SSH



Then, edit the SSH configuration file:

```bash
nano /etc/ssh/sshd_config
```

## Configuring Chroot Environment

### Restrict to user

In the `sshd_config` file, locate or add the following lines to set up a chroot environment:

```bash
Subsystem sftp internal-sftp

Match User username
    ChrootDirectory /home/%u
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
```

Replace `/home/%u` with your desired chroot directory and `username` with the name of the restricted user.

### Restrict to group

In the `sshd_config` file, locate or add the following lines to set up a chroot environment:

```bash
Subsystem sftp internal-sftp

Match Group sftponly
    ChrootDirectory /home/%u
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
```

Replace `/home/%u` with your desired chroot directory and `sftponly` with the group name for restricted users.



## Restarting SSH

Apply changes by restarting the SSH service:

```bash
systemctl restart sshd
```

## Testing the Configuration

Test your setup by connecting through an SFTP client using the newly created user credentials. The user should only access the specified directory.
