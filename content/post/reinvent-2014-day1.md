---
layout: post
title: "AWS re:Invent 2014 day1 のまとめ"
date: 2014-11-12
comments: true
---

AWS が主催する re:Invent 2014 に参加するためにラスベガスに来ております。`@suzu_v` 先生が[メモ書き](http://suzuken.hatenablog.jp/entry/2014/11/13/112730)をしていたので、自分も簡単ながらメモを残しておこうと思います。

<!--more-->

<img src="https://farm8.staticflickr.com/7545/15782079551_8690d5ac80_z.jpg">

## Keynote

[Amazon Aurora](http://aws.typepad.com/aws_japan/2014/11/highly-scalable-mysql-compat-rds-db-engine.html) は 話を聞く限りはかなりイケイケな様子で早く試したいってのと、やっぱり既存のものをクラウドに持ってくだけじゃ不十分ってことで、クラウドだからできることは何かを真剣に考えていくことでこういうものが生まれてくるのでしょう。

[AWS CodeDeploy, AWS CodeCommit, AWS CodePipeline](http://aws.typepad.com/aws_japan/2014/11/new-aws-tools-for-code-management-and-deployment.html) あたりは、ちょうどこの辺を整備しようかと思っていたので最高のタイミングで登場してくれて、若干手間がかかるところやってくれるのは非常にありがたいと思います。

[AWS Config](http://aws.typepad.com/aws_japan/2014/11/track-aws-with-config.html) は、簡単に説明すると AWS のリソース変更履歴を残してくれるもので、ウワサに聞くと任意のタイミングにロールバックなどもできる（ようになる？）だとかで、Route53 あたりも対応してくれるとかなり助かる感じなのではないかと。

## How Dropbox Scales Massive Workloads Using Amazon SQS

ファイルの更新をフックに、そのファイルに関する様々な処理を行うフレームワークについて紹介するセッション。Livefill と呼ばれる非同期処理パイプラインをマネージするフレームワークを SQS を利用して実装していて、開発者は YAML で input/output するキューと処理を記述するだけで非同期処理を追加していけるようになっていてクール。当たり前ですが、パイプラインの可視化がかなり重要で、コードのバグや書き込み先の詰まりなどで容易にパイプラインが詰まることがあるので、この手のものには、可視化することで早期に発見して対策していける仕組みが不可欠ですね。

## Infrastructure as Code

CloudFormation の話な感じだったが、やっぱりJSON はツラい気がした。[Simple](https://www.simple.com/) の事例では Python のスクリプトで JSON 生成してるようだったが、もし使うならなんらかのラッパーが必要そうだなという印象。

## Netflix's Next Generation Big Data Platform

Netflix がいわゆるビッグデータ周りをどのように運用しているかについて、利用しているツール、それを選んだ理由、既存手法とのベンチマーク比較、導入する上での OSS への貢献などについて話をしていました。やはり 2000 台の EMR クラスタみたいな話があったり、規模感が相変わらずすごいです。

最近は社内でも [Presto の MySQL connector](http://prestodb.io/docs/current/connector/mysql.html) を利用して、S3 に置いてあるログと RDS にあるマスタを JOIN できるような環境が整いつつありますが、Presto や Parquet FF の話は大変参考になりました。([関連ブログ](http://techblog.netflix.com/2014/10/using-presto-in-our-big-data-platform.html))

話を聞いていて、アプリケーションとストレージをできるだけ分離しておくことはかなり大切で、例えば Netflix のように基本的にデータを S3 に置くような運用していると、Hadoop v1 と v2 を並行稼働みたいなことが実現できて、バージョンアップ対応とか再起動祭りへの対応負荷がかなり下がりそうなので、この辺りは心がけていきたいですね。

## AWS re:Invent Central

スポンサー企業がブースを出展していて、普段使ってるサービスの開発者やサポートの人と直接会えたり、色々な企業のノベルティ貰えたりととても楽しい場所でした。

### Datadog

1 年半前に [Velocity Conference に参加したとき](http://blog.takus.me/2013/06/21/velocity-conference-santa-clara-2013/)は、会場の隅に小さいブースを持ってるだけだったのですが、この 1 年半で大きく成長したようで、入り口近くにかなり大きなブースを構えるようになっていて、3 年くらい前から密かに Datadog ファンをしていた自分としては嬉しかったです。また、ブースで話をしていたら、"Are you Takumi? Coincidence!!" みたいなノリでいつもメールでサポート対応してくれてる人と出会えて話ができたのもとても有意義でした。

せっかくなので色々とディスカッションしてましたが、エージェントがメモリ使いすぎ問題について聞いたら、Golang でエージェント書いてるみたいな答えが返ってくるなど、こちらの課題感と同じ感覚をちゃんと持ってくれていて、この辺りが 1 年間ですごく成長してる理由の 1 つなのかなと勝手に思ってました。

### Chef

「昔、Chef のベストプラクティスで、コミュニティクックブックをラップしろみたいなのがあったけど、あれは本気か」って聞いてみたところ、コミュニティクックブックはテンプレートとして使うのがいいよと中の人が言っていたので、スッキリしました。

## おわり

ということで、2 日目がそろそろ終わるタイミングでの 1 日目のメモでした。
