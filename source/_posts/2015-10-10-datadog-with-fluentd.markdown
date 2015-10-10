---
layout: post
title: "Dogstatsd で Datadog にカスタムメトリクスを送る方法 〜Fluentd との連携を添えて〜"
date: 2015-10-10 16:45:54 +0900
comments: true
---

[Datadog](https://datadoghq.com) というシステム監視 SaaS のネタです。先週の木曜に「Datadog でカスタムメトリクス送るの面倒じゃない？どうやってるの？」とある人に質問されたので、
自分が知ってる **Dogstatsd** を使う方法をシェアします。

{% img https://farm1.staticflickr.com/647/22081821051_acc8d5bc06_b.jpg 640 480 'flickr.com' %}

これはあるサービスの Nginx のアクセスログとエラーログを、
Fluentd 経由で Datadog にカスタムメトリクスとして送って可視化した例になっていて、
それぞれ、

- 左上: ステータスコード別の集計グラフ
- 右上: 今日・昨日・一週間前のレスポンスタイムグラフ
- 左下: Fluentd の タグ毎の流量
- 右下: Fluentd の ホスト毎の流量

といったグラフになっています。このポストではこんなグラフを作る方法を説明してみます。

## Dogstatsd とは？

{% img https://farm1.staticflickr.com/646/22081408891_e935df85f5_b.jpg 640 220 'flickr.com' %}

唐突に Dogstatsd というものが出てきますが、カスタムメトリクスを送る場合はコイツを使うのが鉄板です。
一言で何物か説明すると Datadog 用に拡張された [StatsD](https://github.com/etsy/statsd) です。(StatsD をご存知ない方はググってみてください)
これは Datadog の監視エージェント (dd-agent) に含まれているので、Datadog を使うなら特に設定なしで使えます。
詳しい説明は [公式ドキュメント](http://docs.datadoghq.com/guides/dogstatsd/) を読むといいでしょう。

## アプリケーションから直接送る方法

これは上で紹介したドキュメントにも "The easiest way" と紹介されているやり方になります。
[Datadog Docs - Libraries](http://docs.datadoghq.com/libraries/) に各言語用のライブラリが紹介されているので、
これらのライブラリを各アプリケーションに組み込むことで好きなように送ることができます。
例えば Ruby のアプリケーションで Page View  を集計する場合は、[DataDog/dogstatsd-ruby](https://github.com/DataDog/dogstatsd-ruby) を下記のように使うだけです。

```ruby
require 'statsd'
# Create a stats instance.
statsd = Statsd.new('localhost', 8125)
# Increment a counter.
statsd.increment('page.views')
```

## Fluentd を経由して送る方法

アプリケーションから直接送る方法は簡単に使える一方で、
Datadog 以外のシステムにメトリクスやアラートを送るのに別の手段が必要になったり、
ミドルウェアからカスタムメトリクスを送りたいような場合に手間がかかったりするため、
自分は、Fluentd を経由する方法を利用することが多いです。

Fluentd を経由することで監視に介在するコンポーネントが増える懸念はありますが、
ほとんどの場合は安定して動いてくれるので実用上の問題はなく、
豊富なプラグインを利用することで、様々なミドルウェアや SaaS との連携が簡単で、
もし仮に監視システムを入れ替えるようなことがあっても、最小限の労力で入れ替えが可能になったり、
複数のシステムにメトリクスを送ることも簡単にできます。

### 設定ファイルの例

よくありそうな例として Nginx のアクセスログから、ステータスコード集計とレスポンスタイム統計を取得する方法について説明します。
全体的な流れとしては、

- [in_tail](http://docs.fluentd.org/articles/in_tail) でログを読み込む
- [out_record_reformer](https://github.com/sonots/fluent-plugin-record-reformer) で好みの形式にレコードを整形する
- [out_dogstatsd](https://github.com/ryotarai/fluent-plugin-dogstatsd) で dogstatsd にメトリクスを送信する

となります。設定ファイルは下記のように配置するとして、それぞれの設定ファイルについて説明していきます。

```
$ tree /etc/td-agent
/etc/td-agent
├── conf.d
│   ├── dogstatsd.conf.erb
│   └── nginx.conf.erb
└── td-agent.conf.erb
```

### td-agent.conf.erb

他の設定ファイルを include するだけです。
[拙作の Datadog エージェントによるバッファ監視](https://www.datadoghq.com/blog/monitor-fluentd-datadog/)を入れると捗るので monitor_agent の設定も入れておきます。

```apache
<source>
  type monitor_agent
  port 24220
</source>
@include conf.d/nginx.conf
@include conf.d/dogstatsd.conf
```

### conf.d/nginx.conf.erb

本筋とそれますが Fluentd v0.12 から使えるようになった[ラベル機能](http://qiita.com/sonots/items/a01d2233210b7b059967)はすごい便利なので、
未だにタグ書き換えで消耗してる人は、ラベルに置き換えると幸福度が増すと思います。

```
## アクセスログを LTSV 形式で取り込む
<source>
  type     tail
  format   ltsv
  path     /path/to/access.log
  pos_file /path/to/nginx.access.pos
  tag      nginx.access
</source>

<match nginx.access>
  type copy

  ## ログ流量監視をするために out_flowcounter にも送る
  <store>
    type       flowcounter
    count_keys *
    unit       second
    aggregate  all
    tag        fluentd.flowcounter.nginx.access
    @label     @dogstatsd
  </store>

  ## @nginx にルーティングする
  <store>
    type   relabel
    @label @nginx
  </store>
</match>

<label @nginx>
  ## out_record_reformer で目的に応じてレコードを整形する
  <match nginx.access>
    type copy
    ## ステータスコード集計用
    <store>
      type record_reformer
      renew_record true
      enable_ruby  true
      tag dogstatsd.increment
      <record>
        type "increment"
        key  ${"nginx.status_#{status[0]}xx"}
        nginx_proto ${forwardedproto}
        nginx_vhost ${vhost}
      </record>
    </store>
    ## レスポンスタイム集計用
    <store>
      type record_reformer
      renew_record true
      tag dogstatsd.histogram
      <record>
        type  "histogram"
        key   "nginx.response_time"
        value ${reqtime}
        nginx_proto ${forwardedproto}
        nginx_vhost ${vhost}
      </record>
    </store>
    ## レスポンスサイズ集計用
    <store>
      type record_reformer
      renew_record true
      tag dogstatsd.histogram
      <record>
        type  "histogram"
        key   "nginx.response_size"
        value ${size}
        nginx_proto ${forwardedproto}
        nginx_vhost ${vhost}
      </record>
    </store>
  </match>

  ## @dogstatsd にルーティングする
  <match dogstatsd.**>
    type   relabel
    @label @dogstatsd
  </match>
</label>
```

## conf.d/dogstatsd.conf

@dogstatsd に投げられたレコードを dogstatsd に投げます。

out_dogstatsd で `flat_tag true` にすると type/key/value 以外のフィールドをメトリクスのタグにしてくれます。
conf.d/nginx.conf で、`nginx_proto` や `nginx_vhost` を入れているのはこの機能のためで、
後で可視化やアラート設定するときにこれらのタグを利用して特定の Virtual Host のみのグラフを表示するといったことが可能になるので、
用途に応じて設定することをオススメします。

またこれも本筋とはそれますが、out_dogstatsd で Datadog の Event も送れるので、
エラーログに特定の文字列が現れたら Datadog に通知するとかも簡単にできて捗る感じです。


```apache
<label @dogstatsd>

  ## flowcounter のログも record_reformer で整形する
  <match fluentd.flowcounter.**>
    type copy
    <store>
      type record_reformer
      renew_record true
      tag dogstatsd.count
      <record>
        key   "fluentd.flowcounter.bytes"
        value ${bytes}
        type  "count"
        fluentd_source ${tag_suffix[2]}
      </record>
    </store>
    <store>
      type record_reformer
      renew_record true
      tag dogstatsd.count
      <record>
        key   "fluentd.flowcounter.count"
        value ${count}
        type  "count"
        fluentd_source ${tag_suffix[2]}
      </record>
    </store>
  </match>

  ## String として送られてくることがあるのでキャストしておく
  <filter dogstatsd.count>
    type  typecast
    types value:integer
  </filter>
  <filter dogstatsd.histogram>
    type  typecast
    types value:float
  </filter>

  ## dogstatsd に送る
  ## flat_tag true にすると type/key/value 以外のフィールドをメトリクスのタグにしてくれる
  <match dogstatsd.**>
    type copy
    <store>
      @id  dogstatsd
      type dogstatsd
      flat_tag true
    </store>
  </match>

</label>
```

あとは Datadog でダッシュボードを作るなり、アラートを作るなり好きにしてください。
ちょっと雑な説明なので分からないことがあれば twitter などで聞いて下さい。

## おわりに

これも木曜に出てきたのですが「Datadog の情報ってインターネットにあまり出てなくないですか」というのがありました。
確かに言われてみればそんな気もするので自分の持ってる知見は積極的に出していけたらなと思います。

