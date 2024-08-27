---
title: Configure FrankenPHP
description: How to configure FrankenPHP.
summary: How to configure FrankenPHP.
date: 2024-08-21
tags: [ "web", "webserver", "HTTP", "php", "CGI"]
keywords: [ "web", "webserver", "HTTP", "php", "CGI"]
draft:  false
aliases: ["/docs/frankenphp/configure"]
---

## Common Patterns

### Matomo

```
}
	frankenphp
	order php_server before file_server

	servers matomo.example.com {
		trusted_proxies static 1.2.3.4
	}
}

matomo.example.com {

	@private-dirs {
		path /config/*
		path /tmp/*
		path /lang/*
	}

	respond @private-dirs 403 {
		close
	}

	root * /var/www/matomo
	php_server
}
```