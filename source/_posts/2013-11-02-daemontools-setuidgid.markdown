---
layout: post
title: "daemontools の setuidgid が supplementary groups 権限をつけてくれない件"
date: 2013-11-02 01:40
comments: true
---

『[daemontools の setuidgid](http://cr.yp.to/daemontools/setuidgid.html)』や 『[補助グループ権限もつけてくれるsetuidgidのようなもの](http://d.hatena.ne.jp/hirose31/20130808/1375965331)』のところに書いてある話なんですが、`daemontools` の `setuidgid` は supplementary groups 権限をつけてくれません。

どういうことかというと、`sysadmin` グループに属する `admin` ユーザがいて、下記のような設定になってるときに、

```bash
$ id admin
uid=2500(admin) gid=2500(admin) groups=2500(admin),2501(sysadmin)

$ ls -l /home/admin/password.pl
-rw-r----- 1 root sysadmin 584 Jul 24 22:47 /home/admin/password.pl
```

下記のような run ファイルで daemon を起動したところ、password.pl が読めないというエラーが出ました。

```bash
#!/bin/sh
exec 2>&1
exec setuidgid admin /path/to/oreno_daemon
```

一見すると、`admin` ユーザは `sysadmin` ユーザに含まれているため権限は問題ないように思えて、実際にコンソールから実行すると読むことができるのですが、前述の通り `setuidgid` は supplementary groups の権限をつけてくれないため、`setuidgid` で指定した `admin` ユーザは下記のようなユーザとみなされ、password.pl を読むことができないというオチでした。

```bash
$ id admin
uid=2500(admin) gid=2500(admin) groups=2500(admin)
```

解決策は、『[補助グループ権限もつけてくれるsetuidgidのようなもの](http://d.hatena.ne.jp/hirose31/20130808/1375965331)』にまとまってますが、[この辺り](https://gist.github.com/kazuho/6181648)を使うのがいいのではないかと思ってる次第です。
