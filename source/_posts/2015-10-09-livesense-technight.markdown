---
layout: post
title: "SmartNews's Journey into Microservices という LT をしてきました"
date: 2015-10-09 05:12:04 +0900
comments: true
---

先週の火曜日の話になりますが [Livesense TechNight](http://made.livesense.co.jp/blogs/431) というイベントで "SmartNews's Journey into Microservices" という LT をしてきました。

{% slideshare 53352746 %}

SmartNews のバックエンドは、ニュース記事のクローラー、その記事の意味を解釈するサービス、サムネイル画像の品質判定をするサービス、記事の閲覧履歴を元に準リアルタイムにランキングを調整するサービス、アプリから記事情報を取得するための API Gateway などの多種多様なサービスで構成される Microservices 的なアプローチを取っていますが、資料の前半でそのあたりに至った背景を説明しつつ、後半は Microservices 化のための施策の一つである [AWS CodeDeploy](https://aws.amazon.com/jp/codedeploy/) によるデプロイ自動化について説明しました。このあたりの話に関しては [Itamae / Auto Scaling / CodeDeploy を用いて deploy フローを刷新した話。そして板前を provisioning した話。 | SmartNews 開発者ブログ](http://developer.smartnews.com/blog/2015/10/01/20151001itamae-autoscaling-codedeploy/) にも説明があるので興味がある方がいましたらご覧くださいませ。

{% img https://farm6.staticflickr.com/5688/21420667983_8146ff7c24_b.jpg 640 640 'flickr.com' %}

{% blockquote @jeffbarr https://twitter.com/jeffbarr/status/649575575787454464 %}
From @takus - SmartNews's Journey into Microservices - [http://bit.ly/1QMM591](http://bit.ly/1QMM591)  (Using #AWS CodeDeploy, #Docker, more)
{% endblockquote %}

また、スライドを公開したところ AWS の Chief Evangelist である Jeff Barr さんが twitter で言及してくれたので、今後もシェアして貰えるような情報発信を定期的にしていけたらなと思いました。
