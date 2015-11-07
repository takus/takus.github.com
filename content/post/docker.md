---
layout: post
title: "Immutable Infrastructure Hackathon :D で docker をさわってみた"
date: 2014-02-23
comments: true
---

Immutable Infrastructure Hackathon :D で [Docker](https://www.docker.io/) を触ってみただけという、ゆるふわなメモです。

<!--more-->

@muddydixon さんや @yosuke_furukawa さんが [drone](http://blog.drone.io/) を触ってたのに比べてだいぶ素人丸出しな感じですが、Docker 童貞からは脱却できたので、次は "[Docker + Jenkins + serverspecでpuppetのmanifestをCIする](http://blog.tmtk.net/2013/09/28/docker-jenkins-serverspec-puppet.ja.html)" あたりに取り組んでみたいと思いました。


## 公式チュートリアル


まず、[公式サイトのチュートリアル](https://www.docker.io/gettingstarted/)で一通り使い方を学びました。

## Docker on DigitalOcean

DigitalOcean は 1GB メモリのサーバが 1 時間 $0.015 で使える格安の VPS サーバで、手元で VM 動かしたくなかったので使ってみました。Docker は "[MacからVagrantコマンド一発でSSDなVPS(DigitalOcean)上にCentOS6.5+Docker環境を構築する](http://blog.glidenote.com/blog/2013/12/20/vagrant-docker-digitalocean/)" を参考に入れます。

最初は CentOS 6.4 に Docker をインストールして docker build していましたが、メモリ枯渇して OOMKiller 発動したり不安定だったので、公式サポートされてるという CentOS 6.5 にしました。ちなみに IPv6 が有効になってると `docker run -p` したときに IPv4 のアドレスを bind してくれなかったので無効にしてます。

## Ukigumo-Server on Docker

Docker が動くようになったので、@kazeburo 先生の "[CentOS 6.5にDockerいれてGrowthForecastを動かしてみた](http://blog.nomadscafe.jp/2013/12/centos-65dockergrowthforecast.html)" を参考に Ukigumo-Server の image を作ってみました。

### Dockerfile

元の Dockerfile では `EXEC` してましたが、 `EXEC` 使うより `ENTRYPOINT` で引数渡せるようにした方が `docker run` するときに引数指定できて便利そうだったのでそうしてます。Dockerfile のコマンドについては、[公式ドキュメント](http://docs.docker.io/en/latest/reference/builder/) が参考になりました。

```
FROM centos
MAINTAINER Takumi Sakamoto, takus
RUN yum -y groupinstall "Development Tools"
RUN git clone https://github.com/tagomoris/xbuild.git
RUN xbuild/perl-install 5.18.1 /opt/perl-5.18
RUN echo 'export PATH=/opt/perl-5.18/bin:$PATH' > /etc/profile.d/xbuild-perl.sh
RUN /opt/perl-5.18/bin/cpanm -n Ukigumo::Server
EXPOSE 2828
ENTRYPOINT ["/opt/perl-5.18/bin/ukigumo-server"]
```

### image を build して docker repository に push

image を作って push してみました。push した image は[コチラ](https://index.docker.io/u/takus/ukigumo-server/)にあります。

```
$ docker login
Username: xxxx
Password:
Email: xxxx
Login Succeeded

$ docker build -t takus/ukigumo-server .
Successfully built 14b737e414c6

$ docker images
REPOSITORY             TAG                 IMAGE ID            CREATED              VIRTUAL SIZE
takus/ukigumo-server   latest              14b737e414c6        About a minute ago   1.33 GB

$ docker run -p 2828:2828 takus/ukigumo-server
d3b31b2f8603344636435d18138a74ff365cc5797f10fe900cc16d05b0451fe0

$ docker push takus/ukigumo-server
d4fc918d1e82: Image successfully pushed
Pushing tag for rev [d4fc918d1e82] on {https://registry-1.docker.io/v1/repositories/takus/ukigumo-server/tags/latest}

```

### 他の人が作った image をもってきてみる

試しに @sonots さんの growthforecast の image をもってきて動かしてみました。

```
$ docker search growthforecast
NAME                            DESCRIPTION   STARS     OFFICIAL   TRUSTED
futoase/docker-growthforecast                 0                    [OK]
sonots/growthforecast                         0

$ docker pull sonots/growthforecast
1c7f181e78b9: Download complete

$ docker run -p 5125:5125 sonots/growthforecast
d3b31b2f8603344636435d18138a74ff365cc5797f10fe900cc16d05b0451fe0
```

こんな感じで雰囲気は分かったのでもう少し触ってみたいと思います。
