+++
date = "2015-12-09T00:00:00+09:00"
title = "Runscope で Web API を監視する"
tags = ["Runscope", "monitoring"]
comments = true
+++

この記事は [Web API Advent Calendar 2015 - Qiita](http://qiita.com/advent-calendar/2015/web_api) の 9 日目の記事です。[Runscope](https://www.runscope.com/) という Web API 監視サービスについて紹介したいと思います。

<!--more-->

## 背景

マイクロサービス化によって、システム全体が API を通して処理をするようになっていく中で、各 API が正しく動いているかどうかを監視したいという要求が出てくるかと思います。

よくある監視として、`/health` といったエンドポイントでアプリケーションを死活監視するといったことをしますが、 実際にはもう少し複雑な条件な監視をしたいケースはよくあります。例えば、あるニュースアプリの記事リストを取得する API があったときに、下記のような監視が手軽に行えると、どうなるでしょう？

- HTTP ステータスは 200 である
- レスポンスタイムは 200ms 以内である
- レスポンスの記事リストは、記事が xx 件以上含まれている
- レスポンスの各記事は、xx 以上のカテゴリから編成される
- レスポンスの各記事は、直近 xx 時間以内に作られている

この API にバグが入って特定のカテゴリの記事しか返さなくなったり、バックエンドのクローラーが止まっていて記事リストが更新されていなかったり、記事のカテゴリ分類のモデルが壊れていたり、という問題が起きたとしても、最終的に生成される API のレスポンスを監視することで問題が起きていることに気づきやすくなる気がしませんか？

そうした監視を簡単に実現できる SaaS として、[Runscope](https://www.runscope.com/) というサービスを見つけたので、紹介したいと思います。

## Runscope について

{{% figure src="/images/runscope-overview.png" %}}

Runscope は Web API の監視サービスで、指定したリクエストヘッダやパラメータをつけて Web API を叩き、その結果に対してバリデーションをかけ、問題があれば通知するような SaaS になります。 Public API については、[世界 12 ヶ所 のロケーション(ほとんど AWS region)](https://www.runscope.com/docs/api-testing/locations#on-premises-agents) から監視ができ、Private API についても、`radar` と呼ばれるエージェントを AWS であれば VPC 内に立てることで、外には公開してない API も監視することができます。

### API リクエストの設定

{{% figure src="/images/runscope-configuration.png" %}}

監視の設定画面はこのような形になっていて、初めての人でも簡単に使いこなせるようになるかと思います。API のエンドポイントやリクエストヘッダなどの設定をチョロッとするだけです。たくさん API があって大変な人のために、[Swagger  の設定をエクスポートして監視定義を作る機能](http://blog.runscope.com/posts/new-import-feature-support-for-swagger-postman) があるので、もし Swagger を使っていれば楽に設定できます。

### API レスポンスのアサーション

レスポンスコード、レスポンスタイム、レスポンスサイズ、レスポンスヘッダ、レスポンスにある文字列が含まれるかなどの単純なアサーションなら、API リクエスト時の設定フォームみたいなところで簡単に設定できます。

{{% figure src="/images/runscope-assertion.png" %}}

背景で説明したようなちょっとリッチなアサーションをする場合、上記の図のように Javascript でアサーションを書けるので、「記事リストに記事が xx 件以上含まれている」とか「各記事は、直近 xx 時間以内に作られている」といったアサーションを記述することができます。

### 各種 SaaS との連携

{{% figure src="/images/runscope-integration.png" %}}

各アサーションの結果は PagerDuty、Datadog、Slack などに通知できるので、production の API に異常があれば PagerDuty でコールする、staging の API に異常があれば Slack に通知する、といった連携が簡単にできます。

また、もし [Datadog](https://www.datadoghq.com/)  を使っていたら、リージョン毎のレスポンスタイムなどが Datadog に記録されていくので、サーバやデータベースのメトリクスと並べて比較ができて、より捗ります。

### 価格

で、気になるお値段ですが、[価格表](https://www.runscope.com/pricing-and-plans)はちゃんと公開されていて、Medium プランだと、$199.0 で月に 100 万回のチェックが行えます。毎分これを走らせることを考えると、23 並列なのでちょっと物足りない感じですが、本番系のクリティカルなところは 1 分単位でチェックして、Staging などの API は 1 時間おきとか、API を更新するタイミングで実行するといった形に融通すれば、この回数に収まる会社が多いのではないでしょうか？

### 信頼性

[Runscope Status - Incident History](http://status.runscope.com/history) を見ると、月に一回くらいは軽微な障害が起きている雰囲気ですが、価格を考えるとこのくらいは妥当なラインな気がします。

### そのほか

さらに、まだ試してないですが、ある  API リクエストによって受け取ったレスポンスの一部を変数に入れて、その次のリクエストに利用するといったこともできるみたいです。これを使うことで、サインアップや商品購入みたいな一連の API の動作もテストすることもできそうな気がします。（監視に対する DB の更新をどうハンドルするかといった問題はありますが。)

## まとめ

AWS Lambda をなどをうまく使えば独自ソリューションで安価に同じようなこともできそうですが、このくらいの価格で使えるのであれば、とりあえず使い始めてしまうのも全然ありかなと思います。ということで、 Runscope という SaaS についての紹介でした。