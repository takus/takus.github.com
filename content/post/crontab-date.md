---
layout: post
title: "crontab で date コマンド使う場合の注意"
published: true
date: 2013-05-01
comments: true
---

crontab で定期的にを実行したときに出力されたものをログとして書き出すときに、ファイル名のサフィックスとして日時をつけることでログローテーションさせたいというケースはあると思います。ですが、以下のような記述はうまくいきません。

    0 0 * * * /home/takus/bin/oreno_script.pl > /tmp/log.`date -d '1 days ago' +%Y%m%d` 2>&1

これは % が crontab では特別な意味を持つ文字であるのが原因で、下記のように % はバックスラッシュでエスケープしておく必要があります。

    0 0 * * * /home/takus/bin/oreno_script.pl > /tmp/log.`date -d '1 days ago' +\%Y\%m\%d` 2>&1

crontab は man を読んで正しく使いましょう。

## 参考

詳細は man 5 crontab で確認できます。
