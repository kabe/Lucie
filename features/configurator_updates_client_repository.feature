# language: ja
機能: コンフィグレータが Lucie クライアント上の設定リポジトリを更新する

  コンフィグレータは
  各 Lucie クライアントの設定を更新するために
  各 Lucie クライアントの設定リポジトリを最新版に更新する

  背景:
    前提 ドライランモードがオン
    かつ 冗長モードがオン

  シナリオ:
    前提 Lucie サーバ上に mercurial で管理された設定リポジトリ (ssh://myrepos.org//lucie) の複製が存在
    かつ コンフィグレータがその設定リポジトリを Lucie クライアント (IP アドレスは "192.168.0.100") へ配置した
    もし コンフィグレータがその Lucie クライアント上のリポジトリを更新した
    ならば Lucie クライアント上のそのリポジトリが "hg pull" コマンドで更新される
    ならば Lucie クライアント上のそのリポジトリが "hg update" コマンドで更新される
