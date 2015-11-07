---
layout: post
title: "Nagios のアラートに CloudForecast へのリンクをつける"
date: 2014-01-28
comments: true
---

といっても、単に `Graph: http://cf.example.com/server?address=$HOSTADDRESS$\n` みたいな記述を `command.cfg` に追加してあげるだけの話です。

<!--more-->

```
define command {
  command_name  notify-service-by-email
  command_line  /usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\n\nService: $SERVICEDESC$\nHost: $HOSTALIAS$\nAddress: $HOSTADDRESS$\nGraph: http://cf.example.com/server?address=$HOSTADDRESS$ \nState: $SERVICESTATE$\n\nDate/Time: $LONGDATETIME$\n\nAdditional Info:\n\n$SERVICEOUTPUT$\n" | @MAIL_PROG@ -s "** $NOTIFICATIONTYPE$ Service Alert: $HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$ **" $CONTACTEMAIL$
}
```

アラートメールは下記のようになるので、メールからすぐにリソースグラフにアクセスできて捗るようになりました。

```
***** Nagios *****

Notification Type: PROBLEM

Service: MEMORY
Host: host0001
Address: 10.0.1.11
Graph: http://cf.example.com/server?address=10.0.1.11
State: CRITICAL

Date/Time: Tue Jan 28 20:08:40 JST 2014

Additional Info:

Ram : 96%, Swap : 0% :  93, 10 : CRITICAL
```

他にも `http://gf.example.com/list/Host/$HOSTALIAS$?t=sh` みたいにして、ホスト名ごとに出力している GrowthForecast へのリンクをつけるみたいにしても便利そうな気がします。
