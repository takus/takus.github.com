+++
date = "2015-12-03T00:00:00+09:00"
title = "AWS CodeDeploy と AutoScaling の組み合わせで気をつけたいこと"
tags = ["AWS", "CodeDeploy", "deployment"]
comments = true
+++

この記事は [AWS Advent Calendar 2015 - Qiita](http://qiita.com/advent-calendar/2015/aws) の 3 日目の記事です。昨日は "[AWS CodeDeploy と CircleCI で Docker コンテナを自動デプロイ](http://blog.takus.me/2015/12/02/docker-with-circleci-and-codedeploy/)" という記事を書きましたが、それに引き続き [AWS CodeDeploy](https://aws.amazon.com/jp/codedeploy/) ネタです。

Fabric や Capistrano などのデプロイツールを利用していると、AutoScaling によって起動してくるインスタンスへのアプリケーションのデプロイをどうするかというのは悩みの種ですが、 AWS CodeDeploy を利用すると、最後にデプロイに成功したリビジョンを起動時にデプロイしてくれるので非常に助かります。その一方で、 AutoScaling と連携して使うときに気をつけておくべきいいポイントがいくつかあるので、それについて書きます。

<!--more-->

## 1. User Data でのプロビジョニングに注意

プロビジョニングも AWS CodeDeploy の hook スクリプトでやることもできますが、アプリケーションのデプロイとプロビジョニングは分けておきたいケースもあります。その場合は User Data にシェルスクリプトを入れて起動時に実行する形にするかと思いますが、2 つほど気をつけた方がいいことがあります。

1 つ目は、EC2 のタグが付与されるタイミングです。Auto Scaling Group でタグを設定しておくと、グループ内のインスタンスにタグをつけてくれるので、タグに応じてプロビジョニングするといった運用ができるのですが、AWS CodeDeploy と AutoScaling を組み合わせる場合、デプロイが終わったあとでないとタグが付与されません。このためタグをベースにプロビジョニングを行う場合は User Data の最初で自身にタグをつけるといったことが必要になります。

2 つ目は CodeDeploy エージェントの起動順序についてです。"User Data の実行" と "CodeDeploy の実行" は特に順序制御の仕組みがないので、AMI に CodeDeploy Agent をインストールして自動起動をしていると、プロビジョニングが終わる前にデプロイされて ELB に追加されてしまう可能性があります。このため、プロビジョニングの最後に CodeDeploy エージェントを起動するようにした方がよいです。

これらを踏まえると User Data は下記のようなスクリプトにしておくのが望ましいかと思います。

```sh
#!/bin/bash

## Role タグと Env タグを付与
aws ec2 create-tags \
  --resources $(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id) \
  --tags Key=Role,Value=api Key=Env,Value=production

## プロビジョニングする (Chef, Puppet, Ansible, Itamae)
aws s3 sync s3://itamae-repo/ /path/to/itamae-repo/ --delete
cd /path/to/itamae-repo && itamae local bootstrap.rb --ohai

## CodeDeploy Agent は最後に起動する
service codedeploy-agent start
```

## 2. スケーリング中のデプロイに注意

AutoScaling によるスケールアウト中に、新たに CodeDeploy のデプロイメント作成を行うと、スケーリングによって新たに追加されたインスタンスへは、最新のリビジョンがデプロイされずにスキップされることがあります。方法は色々と考えられますが、何らかの排他制御をしておく方が安全な気がします。

一方、AutoScaling によるスケールインにも注意が必要で、ログ回収などの終了処理のために自前の LifeCycle Hook を `autoscaling:EC2_INSTANCE_TERMINATING` などに仕込んでいる場合に、この終了処理をしているインスタンスへデプロイするところでデプロイの進捗が止まってしまうことがあります。こちらも排他制御をするか、終了処理はできるだけすぐ終わるようにしておくとよさそうです。

## まとめ

ということで、 AWS CodeDeploy を使う上でいくつか気をつけたい点について説明しました。もうちょっと CodeDeploy さんが賢くやってくれればと思ったりもしますが、

最後になりますが、紹介したもののいくつかは、[Under the Hood: AWS CodeDeploy and Auto Scaling Integration](https://blogs.aws.amazon.com/application-management/post/Tx1NRS217K1YOPJ/Under-the-Hood-AWS-CodeDeploy-and-Auto-Scaling-Integration) という AWS のブログで、Best Practices として書かれていたりもするので、 AWS Code Deploy を使う前には一読をオススメいたします。
