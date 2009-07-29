# language: ja
機能: コンフィグレータが Lucie クライアントに設定リポジトリを配置する

  コンフィグレータは
  設定リポジトリの内容を Lucie クライアントに反映するために
  設定リポジトリを Lucie クライアントへ配置したい

  シナリオ: Lucie クライアントにリポジトリを配置
    前提 ドライランモードがオン
    かつ 冗長モードがオン
    かつ Lucie のテンポラリディレクトリは "/tmp/lucie"
    かつ コンフィグレータ
    かつ Lucie サーバ上に設定リポジトリ (ssh://myrepos.org/lucie) の複製が存在
    もし コンフィグレータがその設定リポジトリを Lucie クライアント (IP アドレスは "192.168.0.1") へ配置した
    ならば 設定リポジトリが scp -r コマンドで Lucie クライアントに配置される
