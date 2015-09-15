---
layout: post
title: "fluent-plugin-dynamodb-streams を作った"
date: 2015-09-15 12:17:48 +0900
comments: true
---

[takus/fluent-plugin-dynamodb-streams](https://github.com/takus/fluent-plugin-dynamodb-streams)

Amazon DynamoDB Streams のレコードを Fluentd で扱いたい要件があり、ググっても見当たらなかったのでプラグインを実装してみました。

## 使い方

[README](https://github.com/takus/fluent-plugin-dynamodb-streams/blob/master/README.md) に書いてある通りですが、こんな設定でお使いいただけます。他の Fluentd のプラグインと組み合わせることで、[AWS Official Blog](https://aws.amazon.com/jp/blogs/aws/new-logstash-plugin-search-dynamodb-content-using-elasticsearch/) にある、Logstash + Elasticsearch のような用途にもお使いいただけるのではないかと思います。

```apache
<source>
  type dynamodb_streams
  stream_arn arn:aws:dynamodb:ap-northeast-1:000000000000:table/table_name/stream/2015-01-01T00:00:00.000
  pos_file /var/lib/fluent/dynamodb_streams_table_name
  fetch_interval 1
  fetch_size 100
</source>
```

また、[example](https://github.com/takus/fluent-plugin-dynamodb-streams/blob/master/example/fluentd.conf) にあるように、
[fluent-plugin-filter-jq](https://github.com/winebarrel/fluent-plugin-filter-jq) と組み合わせると特定の条件で、特定のフィールドだけ取得するみたいなこともできるかと思います。

```apache
<source>
  type dynamodb_streams
  tag stream
  aws_region ddblocal
  stream_arn "#{ENV['STREAM_ARN']}"
</source>

# Only pass MODIFY event
<filter stream>
  type grep
  regexp1 event_name MODIFY
</filter>

# Only keep new_image
<filter stream>
  type jq
  jq '.dynamodb|{new_image:.new_image}'
</filter>

<match stream> 
  type stdout
</match>
```

## そのほか

[Amazon KCL (Kinesis Client Library)](http://docs.aws.amazon.com/ja_jp/kinesis/latest/dev/developing-consumers-with-kcl.html) では、DynamoDB に Checkpoint を保持して耐障害性をあげていたり、ワーカーが並列にレコードを取得することで性能を稼いでいたりしますが、とりあえず自分の要件を満たすのには不要なので実装しておらず、若干不十分なところもありますのでご注意くださいませ。Issue / PR もお待ちしております。
