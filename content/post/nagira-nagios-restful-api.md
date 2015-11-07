---
layout: post
title: "nagira という Nagios RESTful API が便利そうな件"
date: 2013-08-06
comments: true
categories:
---

オートスケーリングみたいなことをしようとする場合、サービスインする前に監視が全て OK になっているかチェック
しておきたいみたいな需要がありますが、みんな大好き Nagios でこれをやろうとするとちょっと面倒だったりします。

<!--more-->

[Nagios::StatusLog](http://search.cpan.org/~duncs/Nagios-Object-0.21.18/lib/Nagios/StatusLog.pm) のようなものを使って `status.dat` をパースする方法がお手軽ですが、監視するホストが数千台みたいな環境だと `status.dat` が結構な大きさになってしまい、必要なたびにパースしてると Nagios が動いてるホストが結構なメモリを喰って swap に入ってしまったり、他のホストに転送してパースするにしてもそれなりに帯域喰ってしまうので、Nagios のホスト上で `status.dat` をパースして一定期間キャッシュし、HTTP でよしなに JSON を返してくれればいいなとか思っていたら、[nagira](https://github.com/dmytro/nagira) でそれが実現できそうだったので試してみました。

ちなみに `nagira` は `NAGIos Restful Api` を意味しているようです。

## インストール

`nagira` は `Sinatra` なアプリなので、`bundler` で適当な場所にインストールします。

```bash
git clone https://github.com/dmytro/nagira.git
cd nagira
bundle install --path vendor/bundle --binstubs
```

nagira 自体には init スクリプトとかを準備してくれる仕組みがあって、conf は RHEL なら `/etc/sysconfig/nagira` を見にいきますが、今回は daemontools を使いたかったので下記のような run ファイルを用意して、conf も `/etc/nagira.conf` あたりにおいておきます。ちなみにキャッシュする時間は `NAGIRA_TTL` で調整できるみたいです。

```bash
#!/bin/sh
exec 2>&1

export APP_ROOT=/path/to/nagira
export RACK_ENV=production
. /etc/nagira.conf

exec setuidgid nagios \
    $APP_ROOT/bin/nagira
```

```
#
# Defaults configuration file for Nagira
# --------------------------------------------
#
# ----------------------
# Port. Default 4567
# ----------------------
NAGIRA_PORT=4567
#
# ----------------------
# BIND
# ----------------------
# String specifying the hostname or IP address of the interface to
# listen on when the :run setting is enabled. The default value –
# '0.0.0.0' – causes the server to listen on all available
# interfaces. To listen on the loopback interface only, use: 'localhost'
#
NAGIRA_BIND=0.0.0.0
#
# ----------------------
# Environment
# ----------------------
# Usually needs to be production
#
RACK_ENV=production
#
# ----------------------
# Nagira user
# ----------------------
# Usually nagira process should be run by same user ID as Nagios. In
# many cases this is nagios user.
#
NAGIRA_USER=nagios
#
# ----------------------
# RVM
# ----------------------
# RVM_STRING="rvm use default"
#
# ----------------------
# Log file
# ----------------------
NAGIRA_LOG=/path/to/nagira.log
#
# ----------------------
# TTL for data
# ----------------------
# Number of seconds between re-parses. All Nagios file are parsed no
# more often than this. Default is 5 sec. Setting this to 0 or
# negative number disables TTL and backgroiund prser as well.
#
NAGIRA_TTL=30
#
# ----------------------
# Background parsing
# ----------------------
# Set this to 0, to disable background parsing.
NAGIRA_BG_PARSING=1
#
# ----------------------
# Nagios configuration file
# ----------------------
# Where main Nagios configuration file is located. usually this does
# not need to change.
#
NAGIOS_CFG_FILE=/path/to/nagios.cfg
```

## 出力例

こんな感じで監視してるホストの一覧とか、サービスの状態が json で取得できるので色々と捗りそうです。ちなみに API は[この辺り](https://github.com/dmytro/nagira/blob/master/docs/API.md)に載っています。また、`| python -mjson.tool` で json 渡すとよしなにやってくれることを昨日知りました。情弱ですいません。

```bash
curl -s http://nagios.example.com:4567/_status/_list | python -mjson.tool
[
    "host0001",
    "host0002",
    "host0003",
    "host0004",
    "host0005",
    "host0006",
    "host0007",
    "host0008",
    "host0009",
    "host0010",
]

curl -s http://nagios.example.com:4567/_status/host0001/_services | python -mjson.tool
{
    "CPU": {
        "acknowledgement_type": "0",
        "active_checks_enabled": "1",
        "check_command": "check_cpu!60",
        "check_execution_time": "0.149",
        "check_interval": "120.000000",
        "check_latency": "0.211",
        "check_options": "0",
        "check_period": "24x7",
        "check_type": "0",
        "current_attempt": "1",
        "current_event_id": "248",
        "current_notification_id": "0",
        "current_notification_number": "0",
        "current_problem_id": "0",
        "current_state": "0",
        "event_handler_enabled": "1",
        "failure_prediction_enabled": "1",
        "flap_detection_enabled": "1",
        "has_been_checked": "1",
        "host_name": "host0001",
        "is_flapping": "0",
        "last_check": "1375751157",
        "last_event_id": "243",
        "last_hard_state": "0",
        "last_hard_state_change": "1374725239",
        "last_notification": "0",
        "last_problem_id": "108",
        "last_state_change": "1374725239",
        "last_time_critical": "1374724999",
        "last_time_ok": "1375751157",
        "last_time_unknown": "1374725119",
        "last_time_warning": "0",
        "last_update": "1375751195",
        "max_attempts": "3",
        "modified_attributes": "0",
        "next_check": "1375751277",
        "next_notification": "0",
        "no_more_notifications": "0",
        "notification_period": "24x7",
        "notifications_enabled": "1",
        "obsess_over_service": "1",
        "passive_checks_enabled": "1",
        "percent_state_change": "0.00",
        "plugin_output": "CPU OK : CPU(Usr) => 0 CPU(Sys) => 0  CPU(IOwait) => 1",
        "problem_has_been_acknowledged": "0",
        "process_performance_data": "1",
        "retry_interval": "8.000000",
        "scheduled_downtime_depth": "0",
        "service_description": "CPU",
        "should_be_scheduled": "1",
        "state_type": "1"
    },
```

## まとめ

Nagios 自体がこの機能を提供してよと思うところもありますが、とりあえずこれでやりたいことは実現できそうなので、もう少し実践的な場面で試していきたい所存です。
