---
title: プライマリドメイン名をMastodonのインスタンスとして使用します
date: '2020-11-10 13:44'
author: 'dallaslu'
license: CC-BY-NC-SA-4.0
taxonomy:
    category:
        - Internet
    tag:
        - Mastodon
        - Nginx
    series:
        - Unify Your Online Accounts
toc:
  enabled: true
---
セルフホストのブログがあり、Mastodonインスタンスを設定する予定がある場合、またはすでに設定している場合は、ドメイン名を選択するという問題に直面する必要があります。ブログが`example.com`であるとすると、Mastodonアカウントは`yourname@example.com`または`yourname@mastodon.example.com`のどちらにする必要がありますか？

===

シンプルさと分かりやすさのためには、当然ながらブログとマストドンのドメイン名を同じにした方が良いでしょう。 しかし、Mastodonは第2階層のディレクトリの下では動作しません。 Mastodonのウェブ部分をリバースエンジニアリングによって第二階層のドメインやディレクトリに移動させたとしても、分散型サービスである本サービスは、連邦宇宙の他のインスタンスノードとデータを交換する際に未知の問題が発生する可能性が高い。

幸い、フェデレーションノード間の通信における重要なステップは、 `https://example.com/.well-known/host-meta`にアクセスすることです。このファイルのコンテンツには、次のステップのURLが含まれています。また、Mastodonは `LOCAL_DOMAIN`および` WEB_DOMAIN`オプションもサポートしています。

## マストドンを設定する

`.env.production`を編集し、次の変更を加えます。

1. __変更しないでください__ `LOCAL_DOMAIN`; 
2. WEB_DOMAIN構成を追加し、`mastodon.example.com`などのセカンドレベルドメイン名に設定します。

## 設定 mastodon.example.com

`mastodon.example.com`のNginxホストを構成するには、Mastodonのドキュメントを参照してください。 Mastodonのstreaming/sidekiq/webサービスを再起動し、nginx構成をリロードすると、`mastodon.example.com`にアクセスできるようになります。

## example.comを設定する

ただし、外部インスタンスがアカウント`yourname@example.com`に接続しようとすると、アドレスがmastodon.example.comであることがわからないため、` https://example.com/.well-known/host-meta`は、 `https://mastodon.example.com/.well-known/host-meta`のコンテンツを返すことができます。

しかし、あなたのアカウントに接続しようとする外部インスタンス `yourname@example.com` は、あなたのウェブアドレスが mastodon.example.com であることをまだ知りません。 known/host-metaは`https://mastodon.example.com/.well-known/host-meta`を返します。

`example.com`のNginx構成で、Mastodonの構成を削除し、次のルールのみを追加します

```nginx
location = /.well-known/host-meta {
       return 301 https://mastodon.example.com$request_uri;
}
```

Nginxをリロードするだけです

## その他の構成

上記の構成は、felxの補足ドキュメント[Mastodonとそれが提供するユーザーに異なるドメイン名を使用する](https://github.com/felx/mastodon-documentation/blob/master/Running-Mastodon/Serving_a_different_domain.md)からのものです。記事で述べたように、メインドメイン名ジャンプとWEB_DOMAIN構成は要件を満たすことができますが、インスタンスバージョンとクライアントの種類が異なるため、依然として奇妙な問題が発生することは避けられません。

また、しばらく実行されているMastodonのプライマリドメイン名からセカンダリドメイン名に切り替えると、より明白な問題が発生する可能性があります。

公式ドキュメントと経験の[ルートの章](https://docs.joinmastodon.org/dev/routes/)によると、互換性を高めるためにexample.comに次のルールを設定することをお勧めします。

```nginx
## mastodon web url
location ~ ^/(about/more|settings|web|pghero|sidekiq|admin|interact|explore|public|@.<em>|relationships|filters|terms|inert.css){
        rewrite ^(.</em>) https://$mastodon_host$1 permanent.
}

## mastodon .well-known

location ~ ^/(.well-known/(host-meta|nodeinfo|webfinger|change-password|keybase-proof-config)|nodeinfo) {
        rewrite ^(.*) https://$mastodon_host$1 permanent.
}

## mastodonのシステムリソース

location ~ ^/(system|headers|avatars) {
        ## set your mastodon public folder, or just redirect to $mastodon_host
        #rewrite ^(.*) https://$mastodon_host$1 permanent;
        root /home/mastodon/live/public;
}

## mastodonのURL (使用可能な post)

location ~ ^/(api/v1|inbox|actor|oauth|auth|users){
        return 308 https://$mastodon_host$request_uri;
}
```

さあ、`yourname@example.com`でおしゃべりしましょう。
