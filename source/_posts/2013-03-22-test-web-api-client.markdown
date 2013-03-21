---
layout: post
title: "Test::Fake::HTTPD で Web API クライアントをテスト"
date: 2013-03-22 03:00
comments: true
---

ある社内向け Web API のクライアントのテスト書く時にどうすべきかなと小一時間調べてみて、[Test::Fake::HTTPD](https://metacpan.org/module/Test::Fake::HTTPD) がよさそうなので使ってみたメモ。思うがままにレスポンス返せるし、実際に本番サーバ叩いたりしなくてもいいし、オフラインでもテストできて、だいぶテストが捗りそうです。

{% codeblock Here's an example of Test::Fake::HTTPD. lang:perl %}
#!/usr/bin/env perl
use warnings;
use strict;

use Test::More;
use Test::Fake::HTTPD;
use JSON::XS;
use Furl::HTTP;

subtest api => sub {

    my $response = {
        '/1/statuses/user_timeline/takus.json?count=1' => [
            {
                'created_at' => 'Thu Mar 21 07:22:25 +0000 2013',
                'text'       => 'Hello, world',
                'user'       => {
                    'screen_name' => 'takus',
                    'lang'        => 'en',
                    'location'    => 'Tokyo, Japan',
                },
                'id' => '314638108048097280',
            }
        ],
    };

    my $httpd = run_http_server {
        my $req = shift;

        if ( $response->{ $req->uri } ) {
            return HTTP::Response->new(
                200, 'ok',
                [ 'Content-Type' => 'text/html' ],
                encode_json $response->{ $req->uri }
            );
        }
        return HTTP::Response->new(
            404,
            $req->uri . " is not found",
            [ 'Content-Type' => 'text/html' ], "{}"
        );
    };

    # API client
    my ( $minor_version, $code, $msg, $headers, $body ) = Furl::HTTP->new()->request(
        method     => 'GET',
        host       => '127.0.0.1',
        port       => $httpd->port,
        path_query => '/1/statuses/user_timeline/takus.json?count=1',
    );

    my $tweet = decode_json($body);
    is $tweet->[0]->{user}->{screen_name}, 'takus', 'screen_name';
    is $tweet->[0]->{id}, '314638108048097280', 'id';
    is $tweet->[0]->{text}, 'Hello, world', 'text';
};

done_testing;
{% endcodeblock %}

## 参考リンク

- [HTTP通信を含むモジュールのテスト](http://perl-users.jp/articles/advent-calendar/2011/test/8)
