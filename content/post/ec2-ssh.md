---
layout: post
title: "EC2 に SSH できない時の対処法、あるいは Marketplace の AMI を気軽に選ぶべきでない理由"
date: 2014-03-04
comments: true
---

前半の部分をまとめようと思ったら、大切なことは全て[ @j3tm0t0 さんの gist ](https://gist.github.com/j3tm0t0/5560892)に書いてあったので、SSH でログインできなくなった時はまず上記の gist に書いてあることを確認するといいと思います。

で、今回の話は、snapshot を取得して 新たに volume を作成して、他のインスタンスにアタッチ＆マウントしてエラーが出ていないかを確認しようとした時に下記のエラーでマウントできなかった件に関するお話です。

<!--more-->

```
'vol-xxxxxxx' with Marketplace codes may not be attached as as secondary device.
```

ググったら ["Is it possible to rescue an EBS volume which has marketplace codes?"](http://www.quora.com/Amazon-EC2/Is-it-possible-to-rescue-an-EBS-volume-which-has-marketplace-codes) や ["Marketplace codes may not be attached as a secondary device"](http://techblog.willshouse.com/2013/08/21/marketplace-codes-may-not-be-attached-as-a-secondary-device/) といった記事を見つけて、まとめると、

* Marketplace で提供される AMI はルートボリューム以外にマウントできない
* AWS のサポートに連絡するとマウントできない制限を解除してくれる

とのことで、AWS のサポートに調査対象ボリュームのスナップショットを共有すると、マウントできない制限を解除してくれるようです。

[CentOS は公式の AMI が Marketplace で提供されてる](https://aws.amazon.com/marketplace/seller-profile/ref=dtl_pcp_sold_by?ie=UTF8&id=16cb8b03-256e-4dde-8f34-1b0f377efe89)のでついつい選んでしまいがちですが、問題が起きた時のトラブルシューティングに一手間かかってしまうので、気軽な気持ちで選んでしまうと面倒なことになるよという話でした。
