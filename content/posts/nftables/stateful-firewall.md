---
sidebar_label: Simple Stateful Firewall
title: "Simple Stateful Firewall with nftables"
tags: [ "security", "firewall"]
description: "Configure a Simple Stateful Firewall with nftables."
---

The nftables is a subsystem of the Linux kernel providing filtering and classification of network packets/datagrams/frames.


Configure a simple firewall for a basic webserver.

```markup
#!/usr/sbin/nft -f

flush ruleset

table inet filter {

	chain inbound_ipv4 {
		icmp type echo-request limit rate 5/second accept
	}

	chain inbound_ipv6 {
		icmpv6 type { nd-neighbor-solicit, nd-router-advert, nd-neighbor-advert } accept
		icmpv6 type echo-request limit rate 5/second accept
	}

	chain input {
		type filter hook input priority 0; policy drop;
		ct state { established, related } accept
		iifname lo accept
		meta protocol vmap { ip : jump inbound_ipv4, ip6 : jump inbound_ipv6 }
		tcp dport 22 accept
		reject
	}

	chain forward {
		type filter hook forward priority 0;
	}

	chain output {
		type filter hook output priority 0;
	}
}
```
