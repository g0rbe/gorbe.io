---
title: "Nginx Configurations"
description: "Reasonable secure settings for nginx"
summary: "Reasonable secure settings for nginx"
date: 2024-08-22
tags: ["nginx", "misconfiguration", "webserver",  "security", "tls", "performance", "proxy", "log"]
keywords: ["nginx", "misconfiguration", "webserver",  "security", "tls", "performance", "proxy", "log"]
draft:  false
thumbnailAlt: Nginx Logo
aliases: ["/docs/nginx/configurations"]
---

## Security configurations

### TLS

Get a certificate from Let's Encrypt:
```bash
certbot certonly --nginx -d example.com --key-type rsa --rsa-key-size 4096
```

Set TLS ciphers in Nginx `server` context:
```nginx
ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
ssl_trusted_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
```

#### Self signed certificate

Generate a self-signed certificate for 5 years:
```bash
mkdir /etc/nginx/default_ssl
openssl req -x509 -nodes -newkey rsa:4096 -keyout /etc/nginx/default_ssl/key.pem -out /etc/nginx/default_ssl/cert.pem -days 1825
```

Configure the certificate in `server` context:
```nginx
ssl_certificate /etc/nginx/default_ssl/cert.pem;
ssl_certificate_key /etc/nginx/default_ssl/key.pem;
```

### Diffie-Hellman parameters

```bash
openssl dhparam -out /etc/nginx/dhparam.pem 4096
```

### Ciphers

List available ciphers:
```bash
openssl ciphers -ciphersuites `openssl ciphers -s -tls1_3`
```

Strongest ciphers
- TLS_AES_256_GCM_SHA384
- TLS_CHACHA20_POLY1305_SHA256
- ECDHE-RSA-AES256-GCM-SHA384
- ECDHE-RSA-CHACHA20-POLY1305
- DHE-RSA-AES256-GCM-SHA384
- DHE-RSA-CHACHA20-POLY1305

Important:
- Priority: AES over ChaCha
- Keysize must be >= 256


Configure TLS ciphers in `http` or `server` context:
```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305;
ssl_prefer_server_ciphers on;
```

#### OpenSSL

If Nginx version >= 1.19.4:


```nginx
ssl_conf_command Options ServerPreference;
ssl_conf_command Ciphersuites TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256;
```

Below Nginx 1.19.4, edit `/etc/ssl/openssl.cnf`:

```bash
Options = ServerPreference
Ciphersuites = TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
```

### Basic authentication

```bash
apt install apache2-utils
```

```bash
htpasswd -c /etc/nginx/.htpasswd user
```

Use it in a `location` context:
```nginx
location /admin {
        auth_basic "Message";
        auth_basic_user_file /etc/nginx/.htpasswd;
}
```

-------------

## Sample configs

### nginx.conf

```nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 1024;
}

http {
        # Basic Settings
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        # Logging Settings
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        # Gzip Settings
        gzip off;

	# Virtual Host Configs
	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}
```

### sites-available/example.com

```nginx
# https
server {

        # Enable SSL and HTTP2
        listen [::]:443 ssl http2;
        listen 443 ssl http2;

        server_name example.com;

        # Set certificate path
        ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/example.com/fullchain.pem;

        # Enable OCSP
        ssl_stapling on;
        ssl_stapling_verify on;
        resolver 1.1.1.1 1.0.0.1;
        resolver_timeout 5s;

        # Add security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy 'strict-origin' always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Strict-Transport-Security "max-age=63072000; includeSubdomains" always;

        # Set root path
        root /var/www/html;
        index index.php index.html index.htm;

        location / {
                try_files $uri $uri/ =404;
        }

        # Set basic authentication to /admin
        location /admin {
                # Basic authentication
                auth_basic "Message";
                auth_basic_user_file /etc/nginx/.htpasswd;
        }

        # Set FastCGI
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                include fastcgi_params;
                fastcgi_param SCRIPT_FILENAME $document_root/$fastcgi_script_name;
                fastcgi_pass unix:/var/run/php/php-fpm.sock;
        }

        # Reverse proxy
        location /proxy {
			proxy_set_header   X-Real-IP $remote_addr;
			proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
			proxy_set_header   Host $host;
			proxy_set_header X-Forwarded-Proto $scheme;
			proxy_http_version 1.1;
			proxy_set_header   Upgrade $http_upgrade;
			proxy_set_header   Connection "upgrade";
            
            proxy_ssl_trusted_certificate /etc/nginx/ssl/cert.pem;
            proxy_ssl_verify       on;
            proxy_ssl_verify_depth 2;
            proxy_ssl_session_reuse on;
            
			proxy_pass http://127.0.0.1:8080;
        }

        # Disable accessing hidden files except .well-known
        location ~ /\.(?!well-known).* {
                deny all;
        }

        # Disable unused methods
        if ($request_method !~ ^(GET|HEAD|POST)$ ) {
                return 405;
        }

		# Custom error pages
		error_page 404 /404.html;
		error_page 500 /500.html;
}

# http
server {

        listen 80;
        listen [::]:80;
        server_name  example.com;

        # Redirect http to https
        return 301 https://$host$request_uri;
}
```

### sites-enabled/default

```nginx
server {

        listen [::]:443 ssl http2;
        listen 443 ssl http2;

        server_name _;

        ssl_certificate /etc/nginx/default_ssl/cert.pem;
        ssl_certificate_key /etc/nginx/default_ssl/key.pem;

        return 444;
}

server {

        listen 80;
        listen [::]:80;
    
        server_name _;

        return 444;
}
```

### conf.d/security.conf

```nginx
# Do not send server version
server_tokens off;

# Set TLS ciphers
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305;
ssl_prefer_server_ciphers on;

# Diffie-Hellman parameters
ssl_dhparam /etc/nginx/dhparam.pem;
ssl_ecdh_curve secp521r1:secp384r1;

# SSL session reuse
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1d;
ssl_session_tickets off;

# Reduce Time To First Byte
ssl_buffer_size 4k;
```

### Basic reverse proxy template

```nginx
# https
server {

        # Enable SSL and HTTP2
        listen 443 ssl http2;

        server_name example.com;

        # Set certificate path
        ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/example.com/fullchain.pem;

        # Enable OCSP
        ssl_stapling on;
        ssl_stapling_verify on;
        resolver 1.1.1.1 1.0.0.1;
        resolver_timeout 5s;

        # Add security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy 'strict-origin' always;
        add_header Strict-Transport-Security "max-age=63072000" always;

        location / {
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;

                proxy_pass http://127.0.0.1:8080;
        }
}

# http
server {

        listen 80;
        server_name  example.com;

        # Redirect http to https
        return 301 https://$host$request_uri;
}
```

## Useful links

- [SSL Test](https://www.ssllabs.com/ssltest/index.html)
- [OWASP Secure Headers Project](https://wiki.owasp.org/index.php/OWASP_Secure_Headers_Project)
- [Security Headers](https://securityheaders.com/)
- [Mozilla Observatory](https://observatory.mozilla.org/)
- [GIXY](https://github.com/yandex/gixy)
- [SSL Configuration generator](https://ssl-config.mozilla.org/)
