require 'rubygems'

require 'facter'
require 'open3'
require 'rbehave'
require 'spec'


ENV[ 'RAILS_ENV' ] = 'test'

require File.dirname( __FILE__ ) + '/../config/boot'
require RAILS_ROOT + '/config/environment'


################################################################################
# helper methods
################################################################################


def sudo_lucied
  "sudo -p '[lucied] password for %u: '"
end


def restart_lucied
  stop_lucied
  start_lucied
end


def start_lucied
  system( "#{ sudo_lucied } ./lucie start --lucied" )
end


def stop_lucied
  if FileTest.exists?( LuciedBlocker::PidFile.file_name )
    system( "#{ sudo_lucied } ./lucie stop --lucied" )
  end
end


def add_fresh_node node_name
  node_dir = File.join( './nodes', node_name )

  FileUtils.rm_rf node_dir
  FileUtils.mkdir node_dir
end


def add_fresh_installer installer_name
  installer_dir = File.join( './installers', installer_name )

  FileUtils.rm_rf installer_dir
  FileUtils.mkdir installer_dir
end


def cleanup_installers
  FileUtils.rm_rf Dir.glob( './installers/*' )
end


def cleanup_nodes
  FileUtils.rm_rf Dir.glob( './nodes/*' )
end


def output_with command
  Popen3::Shell.open do | shell |
    stdout = ''
    stderr = ''

    shell.on_stdout do | line |
      stdout << line << "\n"
    end

    shell.on_stderr do | line |
      stderr << line << "\n"
    end

    shell.exec( command, { :env => { 'LC_ALL' => 'C' } } )

    [ stdout, stderr ]
  end
end


def dummy_ip_address
  my_address = Facter.value( 'ipaddress' )
  /([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)/ =~ my_address
  if $4.to_i < 253
    return "#{ $1 }.#{ $2 }.#{ $3 }.#{ $4.to_i + 1 }"
  else
    return "#{ $1 }.#{ $2 }.#{ $3 }.252"
  end
end


def dummy_gateway_address
  /([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)/ =~ dummy_ip_address
  return "#{ $1 }.#{ $2 }.#{ $3 }.254"
end


# avoid an error caused by rspec 1.1.1
# undefined method `run?' for Test::Unit:Module (NoMethodError)

unless Test::Unit.respond_to?( :run? )
  module Test
    module Unit
      def self.run?; end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
