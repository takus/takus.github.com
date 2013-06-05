---
layout: post
title: "rsync が 'ssh_exchange_identification: Connection closed by remote host' で失敗するときの対処法"
published: true
date: 2013-06-03 01:29
comments: true
---

rsync したときに下記のようなエラーでファイル転送が失敗する事案があったので、
`/etc/sshd_config` の `LogLevel` を `DEBUG 2` に変更して再実行したところ、drop connection されていました。

```bash
$ deploy-tool
.
.
.
err:host0001:65280
ssh_exchange_identification: Connection closed by remote host
rsync: connection unexpectedly closed (0 bytes received so far) [sender]
rsync error: unexplained error (code 255) at io.c(600) [sender=3.0.6]
```

```bash
$ sudo tail -f /var/log/secure | grep 'drop connection'
Jun  1 02:20:40 host0001 sshd[21747]: debug1: drop connection #10
Jun  1 02:20:40 host0001 sshd[21747]: debug1: drop connection #10
```

`man` を見ると `/etc/sshd_config` の `MaxStartUps` が作用してそうだったので `MaxStartups` を大きな値にして回避しました。
外部から攻撃される可能性がないサーバなら大きな値にしておくとよさそうです。

```bash
$ man sshd_config
  MaxStartups
    Specifies the maximum number of concurrent unauthenticated connections to the SSH daemon.
    Additional connections will be dropped until authentication succeeds or the LoginGraceTime expires for a connection.
    The default is 10.

    Alternatively, random early drop can be enabled by specifying the three colon separated values “start:rate:full” (e.g. "10:30:60").
    sshd(8) will refuse connection attempts with a probability of “rate/100” (30%) if there are currently “start” (10) unauthenticated connectios.
    The probability increases linearly and all connection attempts are refused if the number of unauthenticated connections reaches “full” (60).
```

