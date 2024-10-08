---
sidebar_label: NSA-Proof Server
title: "Setup an NSA-Proof OpenSSH server"
tags: [ "OpenSSH", "security", "hardening"]
description: "How to configure an OpenSSH server to the highest security level."
aliases: ["/docs/openssh/nsa-proof-server"]
---

The SSH protocol uses encryption to secure the connection between a client and a server. All user authentication, commands, output, and file transfers are encrypted to protect against attacks in the network. SSH is an Appliaction Layer protocol, uses TCP port 22 by default.

Common softwares that uses SSH protocol:
- OpenSSH
- sftp
- scp
- rsync
- Putty
- sshfs

[What NSA can do with encrypted traffic][1].
The cryptographic algorithms based on stribika's [recommendations][2].

## The config file

OpenSSH reads its configurations from */etc/ssh/sshd_config*.

Before any modification, backup the existing config file:

```
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

Lets look into the details...

Open the config file:

```
sudo nano /etc/ssh/sshd_config
```

## Options

### `Port`

The default port that SSH binds to is 22. Somebody change it to protect himself against bots created by script kiddies (better bots finds the port number anyway).
Im not going to change it, i leave the protection from bots to fail2ban. To change it, modify 22 to any arbitrary number, eg. `Port 2222`. I use the default Port 22.

```
Port 22
```

### `AddressFamily`

Possible options:

- `any` (IPv4 + IPv6)
- `inet` (IPv4)
- `inet6` (IPv6)

Its up to you, i use both IPv4 and IPv6:

```
AddressFamily any
```

### `ListenAddress`

To bind to localhost on IPv4, use ListenAddress 0.0.0.0.
To bind to localhost on IPv6, use ListenAddress ::

```
ListenAddress 0.0.0.0
ListenAddress ::
```

### `SyslogFacility`

The default setting is to log to the security/authentication (`auth`) facility of [syslog][3].
This is good, so its not need to be modified.
The logs can be found in /var/log/auth.log by default.

```
SyslogFacility AUTH
```

### `LogLevel`

This describes the verbosity of the logs.
Logging with a `DEBUG` level violates the privacy of users and is not recommended.

Options: `QUIET`, `FATAL`, `ERROR`, `INFO`, `VERBOSE`, `DEBUG`, `DEBUG1`, `DEBUG2`, `DEBUG3`

The default is:
```
LogLevel INFO
```

### `LoginGraceTime`

Time to wait for authentication before disconnection.
The default is 2 minutes, to disable this feature use `0`.

```
LoginGraceTime 2m
```

### `PermitRootLogin`

Do you want to enable root login? I dont think so...
Disable it!

Use `sudo` or `su -` if you need root.

```
PermitRootLogin no
```

### `StrictModes`

`sshd` check file modes and ownership of the user's files and home directory before accepting login. The deault is `yes` because novices sometimes accidentally leave their directory or files world-writable.

### `MaxAuthTries`

The number of failed authentication atttempt per connection. Once the number of failures reaches half this value, additional failures are logged.
The lower the better, because administrator gets notified earlier and fail2ban reads the log to ban IPs.

```
MaxAuthTries 2
```

### `MaxSessions`

In SSH, it is allowed to use a session for more than one thing (session multiplexing), this is a not a very useful feature for an average user.
To disable it, set it the value to 1.

```
MaxSessions 1
```

### `PubkeyAuthentication`

This allows to login with a secure ssh key.
The default is yes so no need to modify.

```
PubkeyAuthentication yes
```

### `AuthorizedKeysFile`

The file SSH search from the authorized keys.
By default, this is `$HOME/.ssh/authorized_keys`.
`ssh-copy-id` place your key to this file.
Dont modify!

```
AuthorizedKeysFile     .ssh/authorized_keys
```

### `HostbasedAuthentication`

Enables the remote host to authenticate with his HostKey's public key.
It is useful for automated stuffs.
Do you need it? Its up to you.

```
HostbasedAuthentication no
```

### `PasswordAuthentication`

Use clear text password (in an encrypted tunnel) to login.
If no good password policy applied, your server is vulnerable to brute forcing attack.
I always use an SSH key so i disable it, i suggest to do it too!

```
PasswordAuthentication no
```

### `PermitEmptyPasswords`

Do i have to write anything about it?
**NEVER** enable it!
It allows to login in without password.

```
PermitEmptyPasswords no
```

### `ChallengeResponseAuthentication`

Allows to authenticate via challenge-response.
It is possible to setup a 2FA with Google Authenticator for SSH.

```
ChallengeResponseAuthentication no
```

### `KerberosAuthentication`

Do you want to authenticate with Kerberos?

```
KerberosAuthentication no
```

### `GSSAPIAuthentication`

Have you ever heard about GSSAPI? No? Then you need the default no.

```
GSSAPIAuthentication no
```

### `UsePAM`

PAM (**P**luggable **A**uthentication **M**odule) is an authentication framework in Unix. If it is nopt sounds familiar, then disable it.
I dont use it, so the default no remain unchanged.

```
UsePAM no
```

#### `AllowAgentForwarding`

ssh-agent is used to manage your key. You can forward this ssh-agent to a remote host to use your ssh key on the server. This useful if need to operate with your ssh key on the remote server.

Example: authenticate on GitHub with your ssh key, and need to deploy your code on the remote host.

Disabling it dont increase security, but if dont use it worth disabling it, unused feature.

```
AllowAgentForwarding no
```

### `AllowTcpForwarding`

SSH can be used to forward TCP connections. It can forward local port to the remote host, or vice versa. It is a useful feature in SSH.

Disabling it dont increase security.

The case is the same as at AllowAgentForwarding, if you dont need it, disable it.

```
AllowTcpForwarding no
```

### `GatewayPorts`

If you forward a port from remote host to the client, requests only allowed for the server's loopback only by default, so third party can't make a request to the client.
With this option, you can enable it.

```
GatewayPorts no
```

### `X11Forwarding`

Most Linux distributions enables it by default.
X11Forwarding allows to use graphical applications on the server.
Most headless Linux system dont have X at all.

Enabling X forwarding [considered][4] harmfull.

Disable it!

```
X11Forwarding no
```

### `PrintMotd`

**M**essage **o**f **t**he **d**ay can be fun and useful if you create one. Ubuntu has a package (`update-motd`) to generate dynamic messages.
Thats it.
This is shown **after** successful authentication. The banner before authentication is `Banner` below.

```
PrintMotd no
```

### `PrintLastLog`

Do you want to print the last login's details?

It look like this:

`Last login: Fri Dec  6 22:45:44 2019 from [IP]`

It can be useful if you are the only user in the server.

```
PrintLastLog yes
```

### `TCPKeepAlive`

Send TCP keep alive to the other side of the connection. It is useful to properly handle the crash of the other side (eg. network problems, system crash) and kill connection to avoid "ghost" users.

```
TCPKeepAlive yes
```

### `PermitUserEnvironment`

Allows user to set their environment. It can be a security risk if your are managing what a user can do. With an interactive shell, the security risk is zero.

If you are using `~/.ssh/environment` and `environment=` options in ~/.ssh/authorized_keys, enable it.

```
PermitUserEnvironment no
```

### `Compression`

Compression can speed up your connection.
If your internet connection is slow (eg. using SSH over Tor) enable it.

Possible options:

- `no`: no compression
- `delayed`: compresion after successful authentication, this is the default
- `yes`: compress everything

Your choice!

I select not to compress:
```
Compression no
```

### `ClientAliveInterval`

Time to wait in second before sending a null packet on an idle ssh session.
This option is different from TCPKeepAlive. The ClientAliveInterval sends the data in an encrypted tunnel (so not spoofable), while TCPKeepAlive is sent unencrypted (spoofable).
Idle connection **can** be a security problem (eg. client gets comporomised while the connection is open).

First part of disabling idle connection is to set this option to a specific time, eg. 10 minutes:

```
ClientAliveInterval 600
```

### `ClientAliveCountMax`

This sets the number of keep alive packets sent by SSH (not TCPKeepAlive). If the threshold is reached, the SSH server disconnect the client.

This is second (and last) part to disable the idle sessions.
To disconnect the client after 30 minute of idling, set it to 3 (3x600 sec):

```
ClientAliveCountMax 3
```

### `UseDNS`

Do a reverse DNS lookup on the remote IP. This setting is useless because of high chance that the IP dont have reverse DNS setted. Second, it could cause to hang the connection if the DNS server not respond for any reason.

```
UseDNS no
```

### `PidFile`

Pid (process is) file is a simple text file. Programs write the main pid's in it to use it later (eg. kill itself).
If you want to specify the SSH's pid file's location, modify it, else leave it the default setting:

```
PidFile /var/run/sshd.pid
```

### `MaxStartups`

Specify the number of allowed unaunthenticated connections.
The default is 10, its ok.

```
MaxStartups 10
```

### `PermitTunnel`

Do you want to use your ssh server as a proxy?

```
PermitTunnel no
```

### `ChrootDirectory`

chroot is special to Unix systems. Its modifys the current root director (/). If you want to restrict what user can do on your server set it, [a good explanation can be found][5].

```
ChrootDirectory none
```

### `VersionAddendum`

Append text to the SSH protocol banner sent by the server uppon connection.

This is not the login banner below, it is the text that you see when using Nmap with service scan.

```
VersionAddendum none
```

### `Banner`

Banner shows the message before authentication, It reads its content from a file.

This is just a fun factor, so i disabled it:

```
Banner none
```

### `AcceptEnv`

The client can send theit local environment variables to the server.
This options specifies what environment variables are accepted.

The default is not accept anything, but on Debian the default is to accept LANG and LC_*.

```
AcceptEnv LANG LC_*
```

### `Subsystem`

Subsystem is a useful feature of SSH, it is a [set of remote command predefined on the server][6]. if you are interested.

By default, sftp is configured:

```
Subsystem       sftp    /usr/lib/openssh/sftp-server
```

### `AllowUsers`

This creates a whitelist of users that is allowed to log in.
Any other user is disabled. The users are space separated list.

It is useful if you dont have much users to manage on your server.

```
AllowUsers user
```

There are more option to manage users. It will be explained below.

The order of parsing this rules are this, started from the top:

- `DenyUsers`
- `AllowUsers`
- `DenyGroups`
- `AllowGroups`

### `DenyUsers`

This creates a blacklist of users that can't log in.
Any other users that not on the list can log in.
The list of users is a space separated list.

### `AllowGroups`

This option allows user groups to log in.
Only users of this group can login.

This option is useful if you need to manage large number of users.

If you want to use this:

```
# create a group
groupadd ssh-login

# Add the user to the group
usermod -aG ssh-login example

# configure sshd:
...
AllowGroups ssh-login
...
```

### `DenyGroups`

The groups specified in this option can't login. This is the opposite of AllowGroups.


## Crypto

### `KexAlgorithms`

Key exchange algorithm is used to exchange secret between the server and the client, so it should be secure.

There a [list][7] of methods to key exchange, worth reading it. I use the two largest Diffie-Helman algorithms. It may be slower than others!

If you need to use a faster algorithm, use `curve25519-sha256@libssh.org`.

I use the two strongest:

```
KexAlgorithms diffie-hellman-group18-sha512,diffie-hellman-group16-sha512
```

### `HostKey`

Host key is used to authenticate the server to the client. It should be unique to prevent network based attack (eg. mitm).

Stribika suggests not to use DSA/ECDSA because it is depends on random numbers and DSA's key length is only 1024 bits. He is right, so i disable it.

The final config looks like this:

```
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
```

Don't forget to generate larger host keys after the configuration:

```
cd /etc/ssh
rm ssh_host_*key*
ssh-keygen -t ed25519 -f ssh_host_ed25519_key -N "" < /dev/null
ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key -N "" < /dev/null
```

On a new connection, you should see this:

```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
...
```

Remove the known hosts file and it should be fine:
```
rm $HOME/.ssh/known_hosts
```

### `Ciphers`

Ciphers is used to encrypt the data between the client and the server.
It is use a symmetric encryption. The bigger the better.

`ChaCha20` is stream cipher, while AES is a block cipher.

`ChaCha20` is the preferred encryption method is SSH and the de facto standard for stream ciphers, replacing the old and broken RC4.

```
Ciphers chacha20-poly1305@openssh.com
```

### `MACs`

**M**essage **A**authentication **C**ode provides integrity.
Because i use `chacha20-poly1305@openssh.com` for cipher, the MAC is [poly1305][8].

Anyway, i set the strongest MAC to disable the weaks.

```
MACs hmac-sha2-512-etm@openssh.com
```

### `RekeyLimit`

Changing the session key over time to mitigate crypt analysis attacks.
One method to attack cryptography is to collect a huge amount of data to analyse and restore the key.

Changing key too often not suggested.

My options is after 1 gigabyte or 1 hour:

```
RekeyLimit 1G 1h       
```

## The final config file

``` bash
# IP
Port 22
AddressFamily any
ListenAddress 0.0.0.0
ListenAddress ::

# logging
SyslogFacility AUTH
LogLevel INFO

# authentication
LoginGraceTime 2m
PermitRootLogin no
StrictModes yes
MaxAuthTries 2
MaxSessions 1
PubkeyAuthentication yes
AuthorizedKeysFile      .ssh/authorized_keys
HostbasedAuthentication no
PasswordAuthentication no
ChallengeResponseAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no
UsePAM no

# misc
AllowAgentForwarding no
AllowTcpForwarding yes
GatewayPorts no
X11Forwarding no
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
PermitUserEnvironment no
Compression no
ClientAliveInterval 600
ClientAliveCountMax 3
UseDNS no
PidFile /var/run/sshd.pid
MaxStartups 10
PermitTunnel no
ChrootDirectory none
VersionAddendum none
Banner none
AcceptEnv LANG LC_*
Subsystem       sftp    /usr/lib/openssh/sftp-server

# users
AllowUsers CHANGEME

# crypto
KexAlgorithms diffie-hellman-group18-sha512,diffie-hellman-group16-sha512
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key
Ciphers chacha20-poly1305@openssh.com
MACs hmac-sha2-512-etm@openssh.com
RekeyLimit 1G 1h
```


[1]: https://www.spiegel.de/international/germany/inside-the-nsa-s-war-on-internet-security-a-1010361.html
[2]: https://stribika.github.io/2015/01/04/secure-secure-shell.html
[3]: https://en.wikipedia.org/wiki/Syslog
[4]: https://security.stackexchange.com/questions/14815/security-concerns-with-x11-forwarding/14817#14817
[5]: https://www.tecmint.com/restrict-ssh-user-to-directory-using-chrooted-jail/
[6]: https://docstore.mik.ua/orelly/networking_2ndEd/ssh/ch05_07.htm
[7]: https://tools.ietf.org/id/draft-ietf-curdle-ssh-kex-sha2-09.html#rfc.section.3.1
[8]: https://en.wikipedia.org/wiki/Poly1305
