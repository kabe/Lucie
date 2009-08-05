# -*- coding: utf-8 -*-


################################################################################
# HELPERS
################################################################################


class DummyDpkg
  def initialize installed
    @installed = installed
  end


  def installed? scm
    @installed
  end
end


class DummySSH
  def initialize client_initialized, options
    @ssh = SSH.new( options, options[ :messenger ] )
    @client_initialized = client_initialized
  end


  def cp_r ip, from, to
    @ssh.cp_r ip, from, to
  end


  def sh ip, command
    @ssh.sh ip, command
    if /test \-d/=~ command
      raise "test -d failed" unless @client_initialized
    end
  end
end


def regexp_from string
  Regexp.escape string
end


################################################################################
# STEPS
################################################################################


Given /^バックエンドとして ([a-z]+) を指定したコンフィグレータ$/ do | scm |
  @messenger = StringIO.new( "" )
  options = { :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger }
  @scm = scm.to_sym
  @configurator = Configurator::Server.new( @scm, options )
end


Given /^バックエンドの SCM が指定されていないコンフィグレータ$/ do
  @messenger = StringIO.new( "" )
  options = { :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger }
  @configurator = Configurator::Server.new( @scm, options )
end


Given /^コンフィグレータ$/ do
  @messenger = StringIO.new( "" )
  options = { :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger }
  @configurator = Configurator::Client.new( @scm, options )
end


Given /^その SCM がインストールされている$/ do
  @configurator.dpkg = DummyDpkg.new( true )
end


Given /^その SCM がインストールされていない$/ do
  @configurator.dpkg = DummyDpkg.new( false )
end


Given /^設定リポジトリ用ディレクトリがサーバ上に存在しない$/ do
  FileUtils.rm_rf Configuration.temporary_directory
end


Given /^設定リポジトリ用ディレクトリがサーバ上にすでに存在$/ do
  FileUtils.mkdir_p Configuration.temporary_directory
end


Given /^設定リポジトリ用ディレクトリがクライアント上に存在しない$/ do
  options = { :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger }
  @configurator.ssh = DummySSH.new( false, options )
end


Given /^設定リポジトリ用ディレクトリがクライアント上にすでに存在$/ do
  options = { :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger }
  @configurator.ssh = DummySSH.new( true, options )
end


Given /^Lucie サーバ上に ([a-z]+) で管理された設定リポジトリ \(([^\)]*)\) の複製が存在$/ do | scm, url |
  @scm = scm.to_sym
  @url = url
end


Given /^設定リポジトリがクライアント \(IP アドレスは "([^\"]*)"\) 上にすでに存在$/ do | ip |
  @ip = ip
end


Given /^Lucie サーバの IP アドレスは "([^\"]*)"$/ do | ip |
  @lucie_ip = ip
end


Given /^ドライランモードがオン$/ do
  @dry_run = true
end


Given /^冗長モードがオン$/ do
  @verbose = true
end


Given /^Lucie のテンポラリディレクトリは "([^\"]*)"$/ do | path |
  Configuration.temporary_directory = path
end


When /^コンフィグレータが Lucie サーバに設定リポジトリ "([^\"]*)" を複製$/ do | url |
  @url = url
  begin
    @configurator.clone @url
  rescue
    @error = $!
  end
end


When /^コンフィグレータが SCM のインストール状況を確認$/ do
  begin
    @configurator.check_backend_scm
  rescue
    @error = $!
  end
end


When /^コンフィグレータがサーバを初期化した$/ do
  @messenger = StringIO.new( "" )
  options = { :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger }
  configurator = Configurator::Server.new( nil, options )
  configurator.setup
end


When /^コンフィグレータがクライアント \(IP アドレスは "([^\"]*)"\) を初期化した$/ do | ip |
  @ip = ip
  @configurator.setup @ip
end


When /^コンフィグレータが Lucie サーバにその設定リポジトリのローカル複製を作成$/ do
  @configurator.clone_clone @url
end


When /^コンフィグレータがその設定リポジトリを Lucie クライアント \(IP アドレスは "([^\"]*)"\) へ配置した$/ do | ip |
  @ip = ip
  @messenger = StringIO.new( "" )
  options = { :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger }

  @configurator = Configurator::Client.new( @scm, options )
  @configurator.ssh = DummySSH.new( true, options )
  @configurator.install @lucie_ip, @ip, @url
end


Given /^コンフィグレータがその設定リポジトリを Lucie クライアント "([^\"]*)" へ配置した$/ do | name |
  options = { :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger }
  @configurator = Configurator::Client.new( @scm, options )
  @configurator.install @lucie_ip, name, @url
end


When /^コンフィグレータがその設定リポジトリを更新した$/ do
  @configurator.update @url
end


When /^コンフィグレータがその Lucie クライアント上のリポジトリを更新した$/ do
  @configurator.update @ip
  @messenger.string.split( "\n" ).each do | each |
    puts each
  end
end


When /^コンフィグレータが設定プロセスを開始した$/ do
  @configurator.start @ip
end


Then /^"([^\"]*)" コマンドで設定リポジトリが Lucie サーバに複製される$/ do | command |
  @messenger.string.should match( /^#{ regexp_from( command ) }.*#{ regexp_from( @url ) }.*#{ regexp_from( Configurator.convert( @url ) ) }.*/ )
end


Then /^"([^\"]*)" コマンドでローカルな設定リポジトリの複製が作成される$/ do | command |
  from = File.join( Configurator::Server.config_directory, Configurator.convert( @url ) )
  to = from + ".local"
  @messenger.string.split( "\n" ).last.should match( /^#{ regexp_from( command ) }.* #{ regexp_from( from ) } #{ regexp_from( to ) }$/ )
end


Then /^設定リポジトリ用ディレクトリがサーバ上に生成される$/ do
  @messenger.string.chomp.should == "mkdir -p #{ Configuration.temporary_directory }"
end


Then /^設定リポジトリ用ディレクトリがサーバ上に生成されない$/ do
  @messenger.string.should be_empty
end


Then /^設定リポジトリ用ディレクトリがクライアント上に生成される$/ do
  @messenger.string.should match( /ssh .+ root@#{ regexp_from( @ip ) } "mkdir \-p \/var\/lib\/lucie\/config"/ )
end


Then /^設定リポジトリ用ディレクトリがクライアント上に生成されない$/ do
  @messenger.string.should_not match( /^ssh .+ root@#{ regexp_from( @ip ) } "mkdir \-p \/var\/lib\/lucie\/config"$/ )
end


Then /^設定リポジトリが (.+) コマンドで Lucie クライアントに配置される$/ do | command |
  source = File.join( Configuration.temporary_directory, "config", Configurator.convert( @url ) + ".local" )
  @messenger.string.chomp.should match( /#{ command }/ )
end


Then /^その設定リポジトリが "([^\"]*)" コマンドで更新される$/ do | command |
  @messenger.string.split( "\n" ).last.should match( /^#{ regexp_from( command )} .*#{ regexp_from( Configurator.convert( @url ) ) }$/ )
end


Then /^Lucie クライアント上のそのリポジトリが "([^\"]*)" コマンドで更新される$/ do | command |
  @messenger.string.should match( regexp_from( command ) )
end


Then /^設定ツールが実行される$/ do
  @messenger.string.chomp.should match( /make/ )
end


Then /^メッセージ "([^\"]*)"$/ do | message |
  @messenger.string.chomp.should == message
end


Then /^メッセージは空$/ do
  @messenger.string.should == ""
end


Then /^エラーが発生しない$/ do
  @error.should be_nil
end


Then /^エラー "([^\"]*)"$/ do | message |
  @error.should_not be_nil
  @error.message.should == message
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
