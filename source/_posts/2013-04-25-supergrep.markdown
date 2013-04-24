---
layout: post
title: "ブラウザから tail -f log | grep keyword できるツール supergrep"
date: 2013-04-25 00:00
comments: true
---

エンジニアならサーバにログインしてコマンド打てば済む話ですが、世の中には非エンジニアでも tail -f log | grep keyword みたいにログを見れるようにしたいという案件がたまにあるみたいです。自分で書いてもよかったのですが、supergrep というツールがあったので使ってみました。

- [Is It A Bird? Is It A Plane? No, It’s Supergrep!](http://codeascraft.etsy.com/2012/06/28/is-it-a-bird-is-it-a-plane-no-its-supergrep/)
- [esty/supergrep](https://github.com/etsy/supergrep)

## インストール

supergrep は node.js で書かれているので、node のインストールから。node の作法はよく知らないので適当です。

{% codeblock install supergrep lang:sh %}
$ git clone https://github.com/creationix/nvm.git ~/nvm
$ . ~/nvm/nvm.sh

$ nvm install v0.10.5
$ nvm alias default v0.10.5
$ node -v
{% endcodeblock %}

続いて supergrep をインストールして起動します。これだけ。起動時に 'Warning: express.createServer() is deprecated, express' が出るのはご愛敬。

{% codeblock install supergrep lang:sh %}
$ git clone https://github.com/etsy/supergrep.git
$ cd supergrep
$ npm install
$ ./runlocal
{% endcodeblock %}

http://hostname:3000 にブラウザからアクセスするとログが見れる状態になりました。

{% img http://farm9.staticflickr.com/8402/8677559587_e5abefa49e_z.jpg 800 250 %}

## 設定

デフォルトでは /var/log/httpd/{info.log,php.log} を見るようになっていますが、他のログもみたい場合は localConfig.js にログのパスを追加します。他にも IRC にポストできそうな config もありましたが今回は必要してないので調べてません。

{% codeblock localConfig.js lang:javascript %}
    files: [
        {
            name: 'web',
            path: ['/var/log/httpd/info.log', '/var/log/httpd/php.log']
            // you can also do this
            //            filter: function (line, config) {
            //                if (! line.match(config.noisyErrors)) {
            //                    return line;
            //                } else {
            //                    return;
            //               }
            //            }
            //
            //  make sure to define below (in the config namespace):
            //    noisyErrors: new RegExp (/(something to ignore)/),
        },
        // add more files entries here if you want
        {
            name: 'app',
            maxLines: 200,
            path: '/data/oreno/app.log',
        }
    ],
{% endcodeblock %}

このままだとダッシュボードで操作できなかったので下記の設定を static/index.html に追加したり。

{% codeblock static/index.html lang:html %}
<div id="logsource-options" class="display-option-group">
    <label class="display-option" for="log-web">Web: <input id="log-web" class="log-option" type="checkbox" data-log="web" tabindex="120" checked></label>
    <label class="display-option" for="log-app">App: <input id="log-app" class="log-option" type="checkbox" data-log="app" tabindex="120" checked></label>
</div>
{% endcodeblock %}

## tail -f log | grep keyword

見にくいですが、キーワード指定してフィルタリングできます。チェック押せば grep -v もできます。

{% img http://farm9.staticflickr.com/8399/8678666106_1e7cb86c29_z.jpg 800 250 %}

ハイライトもできるので、CRITICAL や、特定のホスト名だけ目立たせてもよさそうです。

{% img http://farm9.staticflickr.com/8265/8678666130_803c58ee4b_z.jpg 800 250 %}

## まとめ

今回は非エンジニアにログを見せるという案件のために使ってみましたが、インストール簡単でそれなりに機能が豊富なので色々と使い道は多そうなツールになっていて、スマホからも見れるので休日のアラート対応などでちょっと Mac 開けないみたいな場合の状況確認なんかにも使えそうです。

同じようなツールに riywo さんが紹介していた [webtail] (http://tech.riywo.com/blog/2013/04/23/webtail-plus-ncat-equals-simple-log-monitoring-slash/) みたいなものもあるみたいで、こちらは標準入力からログを受け取れるあたりがカジュアルでよさそうに思いました。

関係ない話ですが octopress で勝手に capitalize されるのがウザい場合、_config.yml で titlecase: false すると幸せになれるみたいです。
