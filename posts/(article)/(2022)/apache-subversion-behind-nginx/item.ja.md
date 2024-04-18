---
title: NginxリバースプロキシApache Subversion
date: '2022-01-03 00:52'
author: 'dallaslu'
published: true
license: CC-BY-4.0
taxonomy:
    category:
        - Software
    tag:
        - Nginx
        - Apache
        - Subversion
        - Regexp
toc:
  enabled: true
---
Subversionは10年前のもののように聞こえます。特に `mod_dav_svn`。しかし、祖先のコードがどこに配置されているかを言うのは難しいです。要するに、あなたはすでに既製のNginxを持っていて、すでにストリーキングしているコードリポジトリにHTTPSサポートを追加したいのですが、それは `proxy_pass`がそれを行うことができるわけではありません。

===

例えば：

```nginx
upstream subversion{
    127.0.0.1:1080;
}
server{
    listen [::]:443;
    server_name svn.example.com;

    # SSL ...

    location / {
        proxy_pass http://subversion;
    }
}
```

まず、おめでとうございます。`proxy_pass http://subversion/` は使用されていないため、最初のピットは回避されます。末尾の `/`文字により、NginxがURLを自動的にエンコードし、通常の使用に影響するためです。ただし、送信時にすぐに502エラーが発生します。

## COPYおよびDELETEのサポート

Subversionは `https://svn.example.com` をHTTPS接続と見なし、ApacheはHTTPサービスのみを提供するため、リクエストヘッダーの `Destination` は `http://` で始まる必要があります。

すぐに、Stackoverfollowから変更する方法を見つけました。

```nginx
location / {
    proxy_pass http://subversion;
    set $fixed_destination $http_destination;
    if ( $http_destination ~* ^https(.*)$ ) {
        set $fixed_destination http$1;
    }
    proxy_set_header Destination $fixed_destination;
}
```

その後、すべてがOKであることがわかりました。とても良いです、それは本当に2番目のピットに落ちました。

## Nginxの紛らわしい動作

`$fixed_destination` は、`https://` を `http://` に置き換えるだけのように見えます。非常にシンプルで明確で、問題ありません。

トランクから新しいブランチを喜んでコピーするときは、ファイル名に中国語が含まれているファイルを変更し、コンパイルしてテストにスムーズに合格します。次に、トランクにマージして戻すときに、十分に注意すれば、ファイル名がurlencodedされていることがわかります。もちろん、それは中国の名前ファイルを含むだけではありません、想像してみてください、しかしブランチで提出されたすべてのファイルの名前はurlencodedです！そして、urlencodedされたファイル名は、次回ブランチがマージされるときに再びurlencodedされます！

問題は `$fixed_destination` にあります。`http$1` は実際にはNginxによってurlencodedされています。この魔法の問題を回避するために、`Destination`の変更をApacheに任せるか、それをデコードするためのluaスクリプトを作成することにしたかもしれません。ちょっと待って！別の魔法の解決策は次のとおりです。

```nginx
location / {
    proxy_pass http://subversion;
    set $fixed_destination $http_destination;
    if ( $http_destination ~* ^https(?<unencoded_destinaton>.*)$ ) {
        set $fixed_destination http$unencoded_destinaton;
    }
    proxy_set_header Destination $fixed_destination;
}
```

マッチングに使用する通常のグループに名前を追加するだけでOKです...

## 他の

このソリューションは、9年以上前の[Maxim Dounin](https://trac.nginx.org/nginx/ticket/348) からの返信に基づいています。 したがって、**名前付きキャプチャグループを使用して、Nginxの正規表現を使用して変数を変更することをお勧めします**。

10年前のソフトウェアアーキテクチャ、10年前の問題は、10年後もまだ存在しています。 驚くべきことに、10年前のソリューションはまだ機能しています。 