---
layout: post
title: "mysql_secure_installation の中身"
published: true
date: 2013-08-11
comments: true
---

単純に気になったので。5.1 系のソース眺めただけです。

## root ユーザのパスワード文字列を設定

```
# Set the root password
UPDATE mysql.user SET Password=PASSWORD('password') WHERE User='root';
```

## anonymous ユーザを削除

```
# Remove anonymous users
DELETE FROM mysql.user WHERE User='';
```

## リモートからの root ログインを禁止する

```
# Disallow remote root login
DELETE FROM mysql.user
WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
```

## test データベースを削除する

```
# Remove test database
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
```

## 権限を再読み出しする

```
# Reload privilege tables
FLUSH PRIVILEGES;`
```
