---
layout: post
title: "SmartNews's Journey into Microservices という LT をしてきました"
date: 2015-10-09
comments: true
---

先週の火曜日の話になりますが [Livesense TechNight](http://made.livesense.co.jp/blogs/431) というイベントで "SmartNews's Journey into Microservices" という LT をしてきました。

<!--more-->

{{% slideshare ksF1CkWTC5a4UT %}}

SmartNews のバックエンドは、ニュース記事のクローラー、その記事の意味を解釈するサービス、サムネイル画像の品質判定をするサービス、記事の閲覧履歴を元に準リアルタイムにランキングを調整するサービス、アプリから記事情報を取得するための API Gateway などの多種多様なサービスで構成される Microservices 的なアプローチを取っていますが、資料の前半でそのあたりに至った背景を説明しつつ、後半は Microservices 化のための施策の一つである [AWS CodeDeploy](https://aws.amazon.com/jp/codedeploy/) によるデプロイ自動化について説明しました。

その他に小ネタとして、Slack へのデプロイ通知とか [airbnb/interferon](https://github.com/airbnb/interferon) による Datadog アラートの自動生成とかの話も入れましたが、時間なくてほとんど説明しなかったので、このあたりはどこかで話す機会があったらいいなと思っています。

また、スライドを公開したところ AWS の Chief Evangelist である Jeff Barr さんが twitter で言及してくれて、今後も定期的に情報発信をしていこうかなというモチベーションが湧いたのも個人的にはよかったです。

{{% twitter jeffbarr 649575575787454464 %}}

ちなみに、デプロイ自動化の話に関しては [Itamae / Auto Scaling / CodeDeploy を用いて deploy フローを刷新した話。そして板前を provisioning した話。 | SmartNews 開発者ブログ](http://developer.smartnews.com/blog/2015/10/01/20151001itamae-autoscaling-codedeploy/) にも解説があるので興味がある方がいましたらご覧くださいませ。

以上です。
