---
layout: post
title: "fluent-plugin-ec2-metadata という fluentd プラグインを書いてみた"
date: 2014-01-18 13:31
comments: true
---

[takus/fluent-plugin-ec2-metadata](https://github.com/takus/fluent-plugin-ec2-metadata)

前々から fluentd のプラグインを書いてみようと思っていたので、ec2 の metadata をレコードに追加するようなプラグインを書いてみました。プラグインの書き方は @tagomoris 先生の ["fluentdのためのプラグインをイチから書く手順(bundler版)"](http://d.hatena.ne.jp/tagomoris/20120221/1329815126) が大変参考になったので、プラグインを書いてみたい人は見るとよさそうです。あとは、@sonots 先生の [fluent-plugin-record-reformer](https://github.com/sonots/fluent-plugin-record-reformer) をかなり参考にさせていただいたのと、Ruby 初心者なので["パーフェクトRuby"](http://www.amazon.co.jp/exec/obidos/ASIN/4774158798/takus-22/ref=nosim)にもお世話になりました。

## なにをするプラグインか？

```js
### Input
foo.bar {"message":"hello ec2!"}
```

```js
### Output
web.foo.bar {
  "role_tag"      : "web",
  "instance_id"   : "i-28b5ee77",
  "instance_type" : "m1.large",
  "az"            : "us-west-1b",
  "vpc_id"        : "vpc-25dab194",
  "message"       : "hello ec2!"
}
```

たとえばこんな感じにレコードを出力してくれます。先週の月曜日に [Immutable Infrastructure Hackathon at :D](http://blog.livedoor.jp/sonots/archives/35635267.html) というイベントをやっていたときに、EC2 で Immutable Infrastructure 前提ならホスト名ベースででなく EC2 のタグに入れた Role ベースで集計するのがいいのではないか思ったのがきっかけで、それっぽいプラグインがなかったので作ってみた感じです。

{% blockquote @mirakui http://blog.mirakui.com/entry/2013/11/21/reinvent-immutable-infrastructure AWS re:Invent と Immutable Infrastructure %}
サーバに名前をつけるという行為はもはや古い慣習であり、クラウドネイティブな思考を妨げる足かせになります。

クラウドでは、サーバはソフトウェアのように扱われます。いつでも必要に応じて立ち上げ、不要になれば簡単に削除することができます。そのような状況で、サーバ1台1台に手動でユニークな名前をつけていくことは、オートスケールをはじめとするクラウドの恩恵を失うことになります。ではどのようにサーバを管理するべきかというと、DNS で名前をつけるのではなく、 EC2 のタギング機能を使ってサーバの属性を記述し、識別するべきである、と述べられています。
{% endblockquote %}

{% blockquote @stanaka http://blog.stanaka.org/entry/2013/12/01/092642 2014年のウェブシステムアーキテクチャ %}
また、ホストがどんどん新しくなるので、負荷観測の連続性をどのように確保するか、などメトリクス情報の保存や可視化に関する課題もあります。
{% endblockquote %}

@mirakui さんのブログや @stanaka さんのブログにも上記のような内容が書いてあり、AWS 上で fluentd を使っていて EC2 のタグ毎に集計したい場合は役に立つプラグインなのではないかと思っています。

## 設定ファイル

設定ファイルは下記のような感じで、[タグの書き換えに便利な tag_parts](http://y-ken.hatenablog.com/entry/fluentd-how-to-use-tag_parts-placeholder) もサポートしております。EC2 のタグのプレースホルダー名は若干悩んだところですが、aws-sdk で返ってくるフィールド名に合わせて `tagset_xxx` にしました。

    <match foo.**>
      type ec2_metadata

      aws_key_id  YOUR_AWS_KEY_ID
      aws_sec_key YOUR_AWS_SECRET/KEY

      output_tag ${instance_id}.${tag_parts[0]}
      <record>
        tag           ${tagset_name}
        instance_id   ${instance_id}
        instance_type ${instance_type}
        az            ${availability_zone}
        vpc_id        ${vpc_id}
      </record>
    </match>

## 今後について

テストコードが EC2 に依存していて TravisCI ではテストできないので、どうしようか考え中です。CircleCI だと[こんなカンジ](http://d.hatena.ne.jp/naoya/20131215/1387090668)で EC2 にインスタンス立ち上げてよしなにテストしてくれるようなことができそうなので、その辺りを調べてみようかと思っていますが、これ使ってテストすればいいのではというアイデアがありましたら、教えていただけると大変助かります！（Ruby も Fluentd も初心者なので...)

あとは必要最低限のプレースホルダーは用意しましたが、これも使いたいみたいなのがあればお知らせください。もちろんそのほかのバグ報告や PR も Welcome です:D
