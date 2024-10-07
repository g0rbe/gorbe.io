+++
title = "CEH v10: 10 Denial of Service"
date = 2020-02-01T00:00:00+01:00
tags = ["CEH"]
description = "Certified Ethical Hacker v10 Chapter 10: Denial of Service"
summary = "Certified Ethical Hacker v10 Chapter 10: Denial of Service"
keywords = "Certified Ethical Hacker,ethical hacker,ceh,cehv10"
thumbnailAlt = "CEH Logo"
+++

Denial-of-Service is type of attack on which service offered by a system or a network is denied.
Service may either be denied, reduce the functionality or prevent the access.

## Symptoms of DoS attack:

- Slow performance
- Increase in spam email
- Unavailability of a resource
- Loss of access to a website
- Disconnection of a wireless or wired internet connection
- Denial of access to any internet services

## Distributed Denial of Service (DDoS)

In DDoS, multiple compromised systems are involved to attack a target.

The attacker send several connection request to the server with fake return address, so the server can't find a user to send the connection approval.
The authentication process waits for a certain time to close the session.
The attacker is continuously sending requests which causing a number of open connection on the server that lead to a denial of service.

## Categories of DoS/DDoS Attacks

### Volumetric Attacks

Denial of Service attack performed by sending a high amount of traffic towards the target.
Volumetric attack are focused on overloading the bandwidth capability.

### Fragmentation Attacks

DoS attacks witch fragment the IP datagram into multiple smaller size packets.
It requires to reassembly at the destination which requires resources of routers. 

Types:

- UDP and ICMP fragmentation attacks
- TCP fragmentation attacks

### TCP-State-Exhaustion Attacks

TCP-State-Exhaustion Attacks are focused on web servers, firewalls, load balancers and other infrastructure component to disrupt connections by exhausting their finite number of concurrent connections.

Most common state-exhaustion attack is ping of death.

### Application Layer Attacks / Layer 7 DDoS

The application level attack overloads the particular service of a website or application.

## DoD/DDoS Attack Techniques

### Bandwidth Attacks

Bandwidth attack requires multiple sources to generate q request to overload the target.
The goal is to consume the bandwidth completely.

Zombie servers or Botnets used to perform this type of attack.

### Service Request Floods

Attacker flood the request towards a web service or server until it is overloaded.

### SYN Attack / Flooding

The attacker sending a lot of SYN request to tying up a system.
The victim waits for the acknowledgement from the IP address, but there will be no response because the source address is spoofed.
This waiting period ties up a connection "listen to queue", that can tie up for 75 seconds.

### ICMP Flood Attack

Flooding ICMP request without waiting for the response overwhelm the resource of the network device.

### Peer-to-Peer Attacks

Exploit bugs in peer-to-peer servers using Direct Connect (DC++).
Using one or more malicious hosts in a peer-to-peer network to perform the attack.

### Permanent DoS Attack (PDoS)

Permanent DoS attack is focused on hardware sabotage, cause irreversible damage to the hardware.
Affected hardware require replacement or reinstall the software.

Methods:

- **Phlashing** 
- **Bricking a system** : sending fraudulent hardware updates

### Application Level Flood Attacks

Attacker finds the fault and flaws in an application or operating system and exploits the vulnerability to gain control over a system.

### Distributed Reflection Denial of Service (DRDoS)

Attacker uses an intermediary victim which redirect the traffic to a secondary victim.
Secondary victim redirects the traffic to the target.
The intermediary and secondary victim is used for spoofing the attack.

## Botnet

Attacker compromises victims to make bot, which compromise other system to create a botnet.
These botnets are controlled by **Command and Control server** owned by the attacker.
This server is used to send instructions to perform the attack.
