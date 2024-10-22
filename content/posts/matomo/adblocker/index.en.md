---
title: Avoid Ad Blockers with Matomo 
description: How to configure Matomo On-Premise to evade Ad Blockers
summary: How to configure Matomo On-Premise to evade Ad Blockers
date: 2024-10-22
tags: [ "Matomo", "analytics", "adblocker"]
keywords: [ "Matomo", "analytics", "adblocker"]
coverAlt: Avoid Ad Blockers with Matomo Cover
thumbnailAlt: Matomo Logo
#aliases: [""]
---

{{< alert "circle-info" >}}
The idea comes from [Plausible's solution](https://plausible.io/docs/proxy/introduction).
{{< /alert >}}

## Tracking Code

```html
<!-- Matomo -->
<script>
  var _paq = window._paq = window._paq || [];
  /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
  _paq.push(['trackPageView']);
  _paq.push(['enableLinkTracking']);
  (function () {
    var u = "/";
    _paq.push(['setTrackerUrl', u + 'omotam']);
    _paq.push(['setSiteId', '1']);
    var d = document, g = d.createElement('script'), s = d.getElementsByTagName('script')[0];
    g.async = true; g.src = u + 'omotam/script.js'; s.parentNode.insertBefore(g, s);
  })();
</script>
<noscript>
  <p><img referrerpolicy="no-referrer-when-downgrade" src="/omotam?idsite=1&amp;rec=1" style="border:0;"
      alt="omotam img" /></p>
</noscript>
<!-- End Matomo Code -->
 ```

## nginx

Use nginx's [rewrite module](https://nginx.org/en/docs/http/ngx_http_rewrite_module.html)

```nginx
rewrite ^/omotam$            /matomo.php last;
rewrite ^/omotam/script.js$  /matomo.js  last;
```

Reverse proxy the two URLs above:

```nginx
location = /omotam {
        proxy_pass https://matomo.example.com;
        proxy_set_header Host matomo.example.com;
}

location = /omotam/script.js {
        proxy_pass https://matomo.example.com;
        proxy_set_header Host matomo.example.com;
        proxy_buffering on;
        proxy_http_version 1.1;

        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host  $host;
}
```

## Caddy

```caddyfile
rewrite /omotam            /matomo.php
rewrite /omotam/script.js  /matomo.js
```

Reverse proxy the two URLs above:

```caddyfile
@matomo-tracker path /omotam /omotam/script.js

handle @matomo-tracker {
        reverse_proxy  https://matomo.example.com {
                header_up Host "matomo.example.com"
        }
}
```