+++
date = "2015-12-02T00:00:00+09:00"
title = "AWS CodeDeploy と CircleCI で Docker コンテナを自動デプロイ"
tags = ["AWS", "Docker", "CodeDeploy", "CircleCI", "deployment"]
comments = true
+++

この記事は [CircleCI Advent Calendar 2015 - Qiita](http://qiita.com/advent-calendar/2015/circleci) の 2 日目の記事です。ちなみに 1 日目は @stormcat24 さんによる"CircleCIでサクッとビルドチェーンを実現する"お話でした。

{{% twitter stormcat24 671486430548393985 %}}

というわけで、2 日目は、[SmartNews's Journey into Microservices という LT をしてきました](http://blog.takus.me/2015/10/09/livesense-technight/) のスライドで少しだけ触れている、Docker コンテナを AWS CodeDeploy + CircleCI でデプロイする話について、簡単に説明しようと思います。

<!--more-->

## 背景

僕が所属しているスマートニュースという会社では、Java でアプリケーションが書かれていることが多いため、JAR/WAR を持ってきて実行するようなことを CodeDeploy を使った Pull 型デプロイでやっています。一方で、一部のアプリケーションは依存ライブラリの関係などから C++ で書かれているので、 Docker を使うことで C++ のアプリを JAR/WAR と同じデプロイフローに載せて運用できるようにする目的で、この仕組みを用意した形になります。

## 設定方法

アプリケーションのリポジトリは下記のような構造にします。

```bash
$ tree . -L 1
.
├── Dockerfile
├── appspec.yml
├── circle.yml
├── docker
├── scripts
└── src
```

### circle.yml

`dependencies` セクションで、`src` ディレクトリ内のソースコードをコンテナ内でコンパイルして、それを `docker save` コマンドで `docker` ディレクトリ内に書き出しています。

`deployment` セクションでは [CircleCI の CodeDeploy 連携](https://circleci.com/docs/continuous-deployment-with-aws-codedeploy) を利用することで、 新しいコミットが master に push された場合のみ、ビルドしたイメージを S3 にあげて、それを CodeDeploy でデプロイする設定を下記のように書けます。

```yml
general:
  artifacts:
    - docker

machine:
  services:
    - docker

dependencies:
  override:
    - docker info
    - docker build -t yourapp .
    - docker save yourapp | gzip -c > docker/yourapp_docker_image.tar.gz
    - docker images

test:
  override:
    - echo 'Test your application here'

deployment:
  aws:
    branch: master
    codedeploy:
      photoqual:
        application_root: /
        revision_location:
          revision_type: S3
          s3_location:
            bucket: yourbucket
            key_pattern: yourapp/{SHORT_COMMIT}-{BUILD_NUM}.tar.gz
        region: ap-northeast-1
        deployment_group: production
        deployment_config: CodeDeployDefault.OneAtATime
```

### appspec.yml

`files` セクションでは S3 からダウンロードした docker イメージを `/tmp` 下に配置するようにしておき、 `hooks` セクションの ApplicationStart の中で `docker load` コマンドを使って読み込むような形です。

```yml
version: 0.0
os: linux
files:
  - source: docker/yourapp_docker_image.tar.gz
    destination: /tmp
hooks:
  ApplicationStop:
    - location: scripts/deregister.sh
      timeout: 60
    - location: scripts/stop.sh
      timeout: 60
  ApplicationStart:
    - location: scripts/start.sh
      timeout: 60
    - location: scripts/register.sh
      timeout: 60
```

hooks の中で使っている `deregister.sh` や `register.sh` は AutoScaling Group で状態を standby に変更したり、 ELB 操作を行うためのスクリプトになっていて、 [awslabs/aws-codedeploy-samples](https://github.com/awslabs/aws-codedeploy-samples/tree/master/load-balancing/elb) の中のスクリプトを参考に作ります。

`scripts/start.sh` は `docker load` で読み込んだイメージを `docker run` で走らせるために下記のようにします。

```
#!/bin/bash
set -e
docker load -i /tmp/yourapp_docker_image.tar.gz
docker run -d --name yourapp -p 8080:80 yourapp
```

`scripts/stop.sh` は ELB から切り離した後に、 Docker コンテナを削除するような形にしています。

```
#!/bin/bash
set -e
sleep 5
docker rm -f yourapp || true
```

### Slack

後は Slack 通知を設定しておくと、デプロイの成功や失敗を通知してくれるようになるので、デプロイの失敗を自分でトラッキングする必要がなくなるのでオススメです。

{{% figure src="/images/slack-circleci.png" %}}

## まとめ

[Amazon EC2 Container Registry](https://aws.amazon.com/jp/ecr/) が出てきたら、そこに Push して運用しようかなと思ってますが、今のところは S3 にコンテナを置いて Pull 型デプロイするのは権限周りを考えるとリーズナブルなのではないかと思っています。
