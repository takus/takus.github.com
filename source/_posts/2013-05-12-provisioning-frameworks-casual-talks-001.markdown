---
layout: post
title: "Provisioning Frameworks Casual Talks vol.1 に行ってきた #pfcasual"
published: true
date: 2013-05-12 04:18
comments: true
---

金曜日にヒカリエで開催された [Provisioning Frameworks Casual Talks vol.1](https://gist.github.com/studio3104/5417631) に参加 & 少しだけお手伝いしてきたのでまとめ。@zabbiozabbio さんと一緒に 27F のエレベーターホールで待ち受けていたのが自分です。

## serverspec の話

chef + puppet の話というよりも chef 使うにしても、puppet 使うにしても、(Touryo 使うにしても)、serverspec 使って構成管理ツールとは別にサーバの構成をテストすべきだよねという話が印象に残っていて、どの構成管理ツール使うか検討している間に、まずは serverspec でテストするようにしておくのがよさそうかなと思いました。

{% blockquote @gosukenator https://twitter.com/gosukenator/status/332845805079785472 %}
利用してるフレームワークに依存したテストだと、そのフレームワークから少しでも外れたことをやると、それが正しいのか正しくないのか検知できなくなる。それがイヤなので、serverspec のような独立したものをつくった。 #pfcasual
{% endblockquote %}

## で、attribute(config) の管理方法の話

{% blockquote @takus https://twitter.com/takus/status/325125339460296704 %}
serverspec 見てて、attribute + template で設定ファイルの差分確認するような機能あればいいと思ったけど、それやると構成管理ツールのリソース参照しなきゃいけなくて割とフクザツな仕組みになりそうだな...。 
{% endblockquote %}

serverspec 自体は出たときからよさそうだなとは思っていたものの、attribute に入れた内容が設定ファイルに反映されているかみたいなテストをしようとすると上記のような疑問にぶち当たって、serverspec が構成管理ツールに依存するのイケてないなーとか思っていましたが、家に帰って twitter 眺めてたら @riywo 先生がボソっといいことつぶやいてました。

{% blockquote @riywo https://twitter.com/riywo/status/332926378683006977 %}
@sonots あとconfigのみを管理するコンポーネント(サーバ毎に変化する値のAPIサーバ)ができて、provisionとtestが両方それを参照するようにするといい感じの疎結合なんすよね。
{% endblockquote %}

弊社でいえば、たとえば admintool 的なツールが attribute 持っていて、provision と test の両方から参照できるみたいになっていれば、なんとなく上記の問題も解決できそうで、chef-solo -j URL で URL 指定して json 取ってこれると言ってた気がするので、なんかこの辺りうまくやれるツールがあるとよさそうですね:D

### 2013/05/12 23:34 追記

[serverspec でホスト固有の属性値を扱う方法](http://mizzy.org/blog/2013/05/12/2/) で参考になりそうな仕組みが提案されてたので参考にしたいところです。

## 自動更新の話

[@sonots さんのブログ](http://blog.livedoor.jp/sonots/archives/26810152.html) にまとまってる話。自分は自動更新は怖い派ですが、実現できないか考える余地は色々とありそうだと思いました。話に出ていた staging はもちろん @sethvargo 先生がお話していた、environments を使えば production の一部のサーバだけ更新するみたいなこともできそうで、staging → production の一部 →production 全部 (or ブルー・グルーン・デプロイで新しいクラスタにだけ) といったように反映しつつテスト回せば、取り返しがつかなくなる前に気づくことも可能なのかもしれないとか思いました。(話聞いた印象なだけで裏取ったりはしてないですが...）

## 大規模(数百〜10,000台)なら chef-server 一択？

こちらも [@sonots さんのブログ](http://blog.livedoor.jp/sonots/archives/26810152.html) の話ですが、admintool あるので、弊社では chef-solo で十分じゃないかと思ってます。現状でも admintool + touryo で数百~千台くらいのサーバ構成管理はある程度実現できていて、それが admintool + chef-solo + serverspec になってもそれで十分機能するんじゃないかと思います。(あくまで個人的な見解です)

## まとめ

弊社は今のところ Touryo 使っていますが、chef や puppet も着実に進化しているので、そうったツールと比較検討した上で使い続けるなり、乗り換えるなりをする必要はあって、そういう意味では色々と構成管理ツールについて考えるいい機会になりました。主催者及び発表者のみなさま、ありがとうございました。
