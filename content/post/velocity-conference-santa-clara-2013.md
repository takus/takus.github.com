---
layout: post
title: Velocity 2013 に参加 & LT してきました！！
published: true
date: 2013-06-21
comments: true
---

6/18 ~ 6/20 に Santa Clara で開催された [Velocity 2013](http://velocityconf.com/velocity2013/) に参加して来ました。Velocity は Web Performance や Web Operation などが主なテーマで、Google、Facebook、Twitter、Amazon、Yahoo! などをはじめとした様々な企業から 1,000 人以上が参加する大規模なカンファレンスです。いまやよく耳にする *DevOps* というキーワードも [10+ Deploys Per Day: Dev and Ops Cooperation at Flickr](http://www.youtube.com/watch?v=LdOe18KhtT4) という Velocity 2009 のトークで有名になった言葉ですね。

参加するにあたって、@xaicron さんの [勝手に YAPC::NA 2013 に行ってきた！！](http://blog.livedoor.jp/xaicron/archives/54515196.html) と同じく、会社が渡航費、宿泊費、参加費等の全ての費用を負担してくれました！！新卒入社 2 年目の自分をこのような素晴らしいカンファレンスに快く派遣してくれた DeNA++ です。

<img src="http://farm6.staticflickr.com/5448/9083213242_27feaaaca5_z.jpg">

## My Ignite Talk

["不格好経営"](http://www.amazon.co.jp/exec/obidos/ASIN/4532318955/takus-22/ref=nosim)にも載ってる DeNA の創業者である南場さんの言葉に、*"これから会社がどんなに長生きしようとも、地球や宇宙の時間のなかでほんの瞬間の存在になる。けれどもなにか宇宙に引っ掻きキズみたいな証を残したい。"* というものがあります。そこで、Velocity への参加が決まってから、DeNA 社員として何か引っ掻きキズを残せないか考えていたところ、[Ignite Velocity](http://velocityconf.com/velocity2013/public/schedule/detail/29483) という LT のセッションを見つけたので、abstract 書いて応募したところ accept されたので LT してきました。

ご存知ない方のために紹介しておくと [Ignite](http://igniteshow.com/) は 20 枚のスライドを 15 秒づつ流して、5 分間のプレゼンをするというプレゼン形式で、Velocity 2012 では [DevOps に関する話](http://www.youtube.com/watch?v=Xfu47E5MkJo) 等が Youtube にあがってます。

<img src="http://l6.yimg.com/so/7374/9089461762_ef95b9fcf7_z.jpg">

Ignite が近づくにつれてかなり緊張が高まって、スラダンのミッチー並みにトイレに行ってたのですが、さらに始まる直前になって上の写真のような会場だと分かり、「あ、これ無理だ」と思って、ドラゴンボール Z のミスター・サタンみたいに腹痛起こそうか悩んでたわけですが、Citrix のナイスガイが「みんな酒飲んでるし、ミスったって誰も覚えてないよー」的な話してくれたおかげでだいぶ緊張がほぐれて、自分のトークはリラックスして臨めました。

<img src="http://farm4.staticflickr.com/3753/9081016555_9dfbd912a2_z.jpg">

LT は [3 Pupular Ops Tool in Japan](https://speakerdeck.com/takus/3-popular-ops-tools-in-japan) という、(popular がかなり主観ですが) serverspec と GrowthForecast と Fluentd について簡単に紹介するような話で、日本の皆様にはお馴染みの内容ですが、海外の人にとってはちょっとは役立つんじゃないかと思ってこの内容にしました。

{{% twitter sethvargo 347198222206386178 %}}

トーク後に fluentd について聞きに来てくれた人がいたり、色んな人から good job とか interesting みたいなお褒めの言葉をいただいたり、以下のようなツイートを頂けたので、小さいながらも引っ掻きキズを残してこれたんじゃないかと思います。

<img src="http://farm3.staticflickr.com/2856/9089460246_e0477f5467_z.jpg">

そして、色々と声かけてもらった中でも、["Web Operations"](http://www.amazon.co.jp/exec/obidos/ASIN/4873114934/takus-22/ref=nosim) の著者で、Velocity の Program Chair でもある @allspaw が自分のこと覚えててくれて、excellent って言ってくれたのには痺れました(お世辞だと分かっててもw)

{{% twitter takus 347527386927083520 %}}

## Awesome People

<img src="http://farm8.staticflickr.com/7406/9081005095_6f9e32e1e8_z.jpg">

Velocity ではほんとに色んな人に優しくしてもらいました。ホテルでチップ用の紙幣なくて両替しようとしたら $5 にしか変えれないと言われて困ってたら、通りかかった人が、"一昨日のトークよかったよ。あとモバゲーのゲームもやったことあるんだ" って言って 3 ドルくれたり（失礼ながら名前聞くの忘れてしまった...)、Closing Party で Adobe で働いてるジェラール・ピケ似のイケメンと喋ってたらビール奢ってくれたり、思い返すとそんなエピソードばかりでほんとに参加者が素晴らしかったです！

## Awesome Talks

素晴らしいトークがたくさんありましたが、全部紹介しきれないので印象深いものだけ簡単にまとめておきます。もうちょっと踏み込んだものはまた後日...。

<img src="http://farm6.staticflickr.com/5527/9087254909_301923410e_z.jpg">

### Avoiding Performance Regression at Twitter

機能追加やバグフィックスを反映するたびに性能劣化が起きてしまうのをどのように防ぐかといった内容で、[WebPageTest](http://webpagetest.org)、[PhantomJS](http://phantomjs.org)、[ShowSlow](http://showslow.com) といったツールを使って、branch 毎の TTFT (最初のツイートが表示されるまでの時間) を Jenkins でテストしているそうです。性能が劣化するようなら merge させないといった仕組みなので、性能向上はあっても性能劣化は起きないような仕組みが自動で回るようになっている点がスバラシイですね。

{{% twitter marcelduran 348150304862240768 %}}

ちなみに、この話すごくよかったのでスピーカーの @marcelduran にリプライしたら、返ってきたリプライまで素晴らしくてさらに感銘を受けました。犯人捜しするのでなく、犯人を作らないような仕組みを考えられる人になりたいですね。

### Bring the Noise: Making Effective Use of a Quarter Million Metrics

Etsy といえば、*"Graph everything"* とか *"If it moves, graph it"* に代表されるようにとにかく何でもグラフにしてることでお馴染みですが、"たとえグラフの波形が乱れても、誰も見てなかったらそれはスパイクと言えるんだろうか？" というところから、リアルタイム異常検知とそれに似たグラフを自動で見つける [Kale](http://codeascraft.com/2013/06/11/introducing-kale/) の話でした。トークの中で出てきた[このツイート](https://twitter.com/DEVOPS_BORAT/status/281242898165538818)でも言ってるように、不味そうな兆候って後で致命的な問題を招くわけで、先ほどの Twitter の話と同じく、問題が小さいうちに対処できるようにしていく部分に Velocity のカルチャーを感じました。

### Configuration Management Anti-patterns

*"Stop putting upstream modules and cookbooks into your repos"* という berkshelf とか librarian-chef とか使って使いたいバージョン固定すれば、勝手にバージョンアップされてりしても安心だよねって話が印象に残りました。DeNA のように大規模に色々なシステムが動くような環境で DRY に則って共通化すると、ある環境のために加えた変更が、他の環境に影響を及ぼしてしまうことがたびたびありますが、使う環境毎にきちんとバージョン固定しておけば、そういう苦しみから解放されて、共通化を進めやすくなり、みんなハッピーになれそうだと思いました。

## Future  

Velocity に行って日本のエンジニアのレベルはやっぱ高いんだなと感じました。例えば 3 日目に聞いた MHA のトークはチュートリアル的な内容に留まっていたので、じゃあ DeNA でどのように MHA を運用してるのかって話なんかは当然喋らせてもらえそうで、DeNA のようにグローバルカンパニーを自負する会社や、日頃から素晴らしいツール・ライブラリを公開してるエンジニアの方々はどんどん海外のカンファレンスで喋っていったらいいんじゃないでしょうか！

自分自身については、エンジニアとしてまだまだ半人前の存在だと再認識しながらも、Velocity の本セッションもそんなに遠い場所でないという感触は掴めたので、いつかは本セッションでトークできるように日頃から精進していきたいと思います:D

## Acknowledgments

最後になりましたが、Velocity に参加するための手配を色々と整えてくれたスーパーヘルパー様と、自分がするべきだった仕事を代わりに引き受けてくださった部署の皆様に心から感謝してます。@katemats が [If You Don't Understand People, You Don't Understand Ops](http://www.youtube.com/watch?v=RGFGdFS_3Cc) というトークで *You get what you give.* って言ってましたが、今回与えてもらった分は必ずお返しします。本当にありがとうございました！
