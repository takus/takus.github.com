---
layout: post
title: "innodb_stats_on_metadata に要注意"
date: 2013-12-21 18:25
comments: true
---

一日に数回 MySQL が詰まるような現象があったので原因を調べたところ、そのサーバだけ `innodb_stats_on_metadata=1` になっていたのが原因だったという話デス。

`innodb_stats_on_metadata` は、テーブルのメタデータにアクセスしたときに InnoDB の統計情報を更新するかどうかのフラグで、今回問題が起こっていたサーバのようにデータ量が多いサーバなどでは無効にしておく必要があります。例えば、[公式ドキュメント](http://dev.mysql.com/doc/refman/5.1-olh/ja/innodb-parameters.html#sysvar_innodb_stats_on_metadata) の `innodb_stats_on_metadata` の部分にはこのように書いてあります。

> この変数が有効 (この変数が作成される前からのデフォルト) な場合、`SHOW TABLE STATUS` や `SHOW INDEX` などのメタデータステートメントの実行時や、`INFORMATION_SCHEMA` テーブル `TABLES` または `STATISTICS` へのアクセス時に、InnoDB は統計情報を更新します。(これらの更新は、`ANALYZE TABLE` で行われるものに似ている。) 無効な場合、InnoDB はそれらの処理中に統計情報を更新しません。この変数を無効にすると、テーブルやインデックスを多数含むスキーマへのアクセス速度が改善される可能性があります。またその場合、InnoDB テーブルが関係するクエリーの実行計画の安定性も高まる可能性があります。

他にも MySQL Performance Blog の [Solving INFORMATION_SCHEMA slowness]( http://www.mysqlperformanceblog.com/2011/12/23/solving-information_schema-slowness/) という記事や、High Performance MySQL 3rd Edition の 5 章にもこのオプションに関する言及がありました。

性能に影響与えるようなオプションであればデフォルトで無効にしておいてくれればいいのにと思っていたら、[MySQL 5.6 からデフォルトで無効](https://blogs.oracle.com/supportingmysql/entry/server_defaults_changes_in_mysql)になるようです。
