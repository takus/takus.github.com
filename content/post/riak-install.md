---
layout: post
title: "CentOS に Riak をインストール & Data::Riak::Fast で操作してみる"
date: 2013-03-28
comments: true
---

最近、社内 TechTalk で何か話せという依頼があり、ちょうど [Riak Serious Talk](http://www.zusaar.com/event/563010) もあるので、[Riak](http://docs.basho.com/riak/latest/) についてアーキテクチャから利用例まで調べて話してみました。その課程で Riak のインストール等したので適当にブログっておきます。

## インストール

[Vagrantbox.es](http://www.vagrantbox.es/) から [CentOS 6.4 x86_64 Minimal](http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130309.box) を持ってきてテストサーバを用意。起動後にひとまず iptables だけ停止。Vagrant の操作などは割愛します。

### 依存パッケージ導入

Erlang をインストールするのに必要なパッケージをインストールします。

```bash
sudo yum groupinstall “Development tools”
sudo yum install git
sudo yum install libwx unixODBC.x86_64 unixODBC-devel.x86_6 wxBase.x86_64 wxGTK.x86_64 wxGTK-gl

wget https://elearning.erlang-solutions.com/couchdb//rbingen_adapter//package_R15B01_centos664_1333462308/esl-erlang-R15B01-1.x86_64.rpm
sudo rpm -ivh esl-erlang-R15B01-1.x86_64.rpm
```

### Riak をインストール

とりあえず make まで。ソースは [Basho のサイト](http://docs.basho.com/riak/latest/downloads/)から入手できます。

```
wget http://downloads.basho.com.s3-website-us-east-1.amazonaws.com/riak/1.3/1.3.0/riak-1.3.0.tar.gz
tar zxvf riak-1.3.0.tar.gz
cd riak-1.3.0
make devrel
```

### Riak を起動してみる

4 ノードを起動。ulimit しているのはなしだと警告が出るので一応。

```
ulimit -n 4096
dev/dev1/bin/riak start
dev/dev2/bin/riak start
dev/dev3/bin/riak start
dev/dev4/bin/riak start
```

起動しただけではノード同士は接続されてない状態なので、ノード同士を接続します。

```
dev/dev2/bin/riak-admin cluster join dev1@127.0.0.1
dev/dev3/bin/riak-admin cluster join dev1@127.0.0.1
dev/dev4/bin/riak-admin cluster join dev1@127.0.0.1
```

## Data::Riak::Fast で操作してみる

Perl のクライアントとして、[Net::Riak](http://search.cpan.org/~franckc/Net-Riak/) が以前からありますが、[ベンチマーク](https://gist.github.com/myfinder/5232845)すると遅いらしいです。@myfinder さんが [Riak::Lite](https://github.com/myfinder/p5-riak-lite)、[Data::Riak::Fast](https://github.com/myfinder/p5-data-riak-fast) を作ってくれているので、Data::Riak::Fast を使って操作してみます。

```perl
#!/usr/bin/env perl
use strict;
use warnings;

use Data::Dumper;
use Data::Riak::Fast;
use JSON::XS;

my $riak = Data::Riak::Fast->new(
    transport => Data::Riak::Fast::HTTP->new(
        host => '192.168.33.10',
        port => '10018',
    ),
);

# stats
my $stat = $riak->stats();
print Dumper($stat);

# bucket
my $bucket = $riak->bucket('my_bucket');

# put
$bucket->add('foo', 'bar');

# get
my $foo = $bucket->get('foo');
```

## まとめ

Riak の利用例みてたら node.js + Riak + Redis で [clipboard.com](http://clipboard.com/) を作ってるとか、色々と面白そうな使い方してる例が多そうで、特に [GitHub Pages のホスティングの話](https://speakerdeck.com/jnewland/github-pages-on-riak-and-webmachine) がよさげだったので、同じような仕組み作ってみたいとか思ってる次第です。

## 参考等

- [Riak && Riak CS](https://speakerdeck.com/kuenishi/riak-and-and-riak-cs)
- [Learn You Some Riak](https://speakerdeck.com/wfarr/learn-you-some-riak)
- [Building a Social Application on Riak - Gary Flake, RICON2012](https://vimeo.com/52417831)
