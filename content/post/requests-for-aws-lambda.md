+++
date = "2015-12-07T00:00:00+09:00"
title = "AWS Lambda のココが惜しい"
tags = ["AWS", "Lambda", "deployment"]
comments = true
+++

この記事は [今年もやるよ！AWS Lambda縛り Advent Calendar 2015 - Qiita](http://qiita.com/advent-calendar/2015/lambda) の 7 日目の記事です。8 日ですけど 7 日目の記事です。つまり書くのを忘れてしまってました。すいません。

今年の re:Invent 2015 では [スケジュール実行、VPC サポート、実行時間の延長](https://aws.amazon.com/jp/blogs/aws/aws-lambda-update-python-vpc-increased-function-duration-scheduling-and-more/) などが発表されて、実用段階が近づきつつある AWS Lambda ですが、汎用ジョブスケジューラーとして使うにはちょっと足りない点について、思いつくことを書いてみようと思います。(もし、それできるよみたいのがあればコッソリ教えてください...)

<!--more-->

## 各種リソース使用量の制限

[AWS Lambda の制限](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/limits.html)に色々と書いてありますが、一時ディスク容量 500 MB 以内、実行時間は最大 300 秒以内というのはちょっと足りない気がします。VPC 対応したら Amazon RDS にも繫げるようになるので活躍の幅は広がりそうだと思っていますが、1 日に 1 回 mysqldump するみたいなことは、この制限によって難しそうな雰囲気がします。

## スケジュール実行が 5 個しか指定できない

せっかく登場したスケジュール実行ですが、[AWS アカウント毎に、最大 5 つまでの指定](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/getting-started-scheduled-events.html) しかできないようです。これはそのうち緩和されることを願うばかり...。

## 関数ごとの同時実行数を制限できない

並列に実行してくれるのは Lambda のいいとこではありますが、例えば何かのイベントをトリガーに DB や Redis に書き込みをするようなケースでは、逆に同時実行数を制限したいケースも出てきそうです。工夫すれば色々と方法はありそうですが、スロットリングしたときにイベントを捨てるのか、何回かリトライするのかを含めて、Lambda の設定だけでできると嬉しい気がします。

ということで、投稿が遅れた上に内容が少なめですが、まずは上記の 3 点が解決されると個人的には嬉しいです。AWS サンタさん、よろしくお願いいたします。
