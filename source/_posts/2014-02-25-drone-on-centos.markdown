---
layout: post
title: "Docker/Drone を CentOS 6.5 で動かして Github Enterprise のリポジトリをテストする"
date: 2014-02-25 20:03
comments: true
---

{% img http://farm6.staticflickr.com/5530/12768732363_934e22c97b_z.jpg 640 374 'Drone by Takumi Sakamoto (takus) on flickr.com' %}

"Docker 使うなら Ubuntu だろ jk" とか言われそうですが CentOS 6.5 で使いたかったので試してみました。[Docker の公式サイトには "Our recommended installation path is for Ubuntu linux, because we develop Docker on Ubuntu and our installation package will do most of the work for you." と書いてあったり](https://www.docker.io/gettingstarted/)、[Drone は Ubuntu 用のパッケージしかなかったり](https://github.com/drone/drone)するので、深淵な理由がなければ Ubuntu 使うのがいいんじゃないかと思います。

## Docker のインストール

CentOS 6.5 なら簡単にインストールできるので特にハマりどころはありませんでした。

```
rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
yum -y install docker-io
chkconfig docker on
service docker start

docker run centos /bin/echo "Hello World"
Hello World
```

## Drone のビルド

Makefile がリポジトリに入ってるので、Makefile でビルドしてあげます。`make deps` でこける場合は適宜、依存を解決してあげれば OK です。
golang 素人すぎて適当にやってしまいましたが、こうすべきみたいのがあれば優しく教えていただけると助かります。

```
yum -y install golang
echo 'export GOPATH=$HOME/go' >> ~/.bash_profile
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bash_profile
source ~/.bash_profile

yum -y install git hg bzr
yum -y groupinstall "Development Tools"

git clone https://github.com/drone/drone.git && cd drone
make deps
make && make test && make install
droned
```

## Drone で Github Enterprise のリポジトリをテストする

後は [Droneのオープンソース版を試してみました。](http://yosssi.hatenablog.com/entry/2014/02/08/161500) に従ってセットアップしていけばいいのですが、Github Enterprise のリポジトリを CI する場合はちょっとだけ対応が必要でした。

### 1. Github API の URL 変更

http://DRONE_HOST/account/admin/settings の "GitHub Settings" で API の URL の変更します。
Github Enterprise の場合は GITHUB_DOMAIN / https://GITHUB_DOMAIN/api/v3 のように修正すればよさそうです。

### 2. リポジトリの clone 方法の変更

[GitHub Enterprise & Private Mode #91](https://github.com/drone/drone/issues/91) にあるように、GitHub Enterprise を private mode で運用してる場合、`git://` プロトコルが使えないので、リポジトリの clone に失敗してしまっていました。Issue にあがってるくらいなのでそのうち解決されるかと思いますが、ワークアラウンドとして下記のようにソースを修正してビルドし直して使ってます。

```diff
--- a/pkg/model/repo.go
+++ b/pkg/model/repo.go
@@ -24,7 +24,7 @@ const (
 )

 const (
-       githubRepoPattern           = "git://%s/%s/%s.git"
+       githubRepoPattern           = "git@%s:%s/%s.git"
        githubRepoPatternPrivate    = "git@%s:%s/%s.git"
        bitbucketRepoPattern        = "https://bitbucket.org/%s/%s.git"
        bitbucketRepoPatternPrivate = "git@bitbucket.org:%s/%s.git"
```

### 3. Github リポジトリにデプロイキーを登録

これで万事解決と思いきや、今度は `git@` で clone してるにも関わらず、git clone に失敗する現象に遭遇しました。Drone のログをみてるとコンテナの初期化する際にリポジトリ毎の秘密鍵をおいているようで、Settings の Key Pairs にある公開鍵を Github リポジトリのデプロイキーに登録してあげたところ、無事に Clone できるようになりました。

{% img http://farm6.staticflickr.com/5475/12768591305_b2c6f232ee_z.jpg 640 310 'Drone by Takumi Sakamoto (takus) on flickr.com' %}

## まとめ

ということで、無事に Drone 使えるようになったので、あとは各バージョンの perlbrew とか rbenv とか nodebrew を持ったイメージを作っておいて、それ毎にバージョン跨ぐテストしていくような感じにしていけばよさそうな雰囲気です。ざっと設定画面とコードを眺めたところ、Jenkins の Master/Slave みたいな仕組みがないので、数が増えていったらある程度 Drone を分けるしかなさそうですが、とりあえずはチーム毎とかそういう単位で Drone を用意してあげればいいのかなと思ってます。 Enjoy your test with Drone :D
