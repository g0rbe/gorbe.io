---
title: Configure MongoDB Community Edition
categories: [ "db", "nosql"]
description: How to configure MongoDB Community Edition.
#image: /assets/docs/caddy/install/image-en.webp
---

import PasswordCodeBlock from '../../src/components/PasswordCodeBlock';

<PasswordCodeBlock 
symbols={0} language={'bash'} tokens={[{name: "MONGODB_DB_PASSWORD"}]}>
{`mongosh --eval='use dbname'--eval='db.createUser({ user: "username", pwd: "MONGODB_DB_PASSWORD",  roles: [ "readWrite" ] })'`}
</PasswordCodeBlock>