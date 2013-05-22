---
layout: post
title: "CentOS 6 に /dev/sdf としてアタッチした EBS ボリュームが /dev/xvdj として認識される件"
published: true
date: 2013-05-23 02:36
comments: true
---

インスタンスガチャなのかなんなのか、同じくらいの負荷与えてる EBS ボリュームのうち 1 台だけ性能劣化することがあって、ひとまず EC2 の問題なのか EBS の問題なのか切り分けるために EBS ボリュームを作って、AWS のマネジメントコンソールから CentOS 6 のサーバに /dev/sdf としてアタッチしたのに一向にデバイス認識されず、おかしいなと思って調べていたらアタッチしたボリュームと同じサイズのデバイスがあって、ググったら RHEL 6 や CentOS 6 でデバイス名がズレてしまうバグが存在するというオチでした。

``` bash
# fdisk -l
.
.
.
Disk /dev/xvdj: 429.5 GB, 429496729600 bytes
255 heads, 63 sectors/track, 52216 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000

Disk /dev/xvdj doesn't contain a valid partition table
```

## 参考リンク

- [CentOS6.2でEBSをマウントする方法](https://forums.aws.amazon.com/thread.jspa?messageID=336352)
