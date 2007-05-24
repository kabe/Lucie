#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require 'fileutils'


class Installers
  def self.load_all
    Installers.new( Configuration.installers_directory ).load_all
  end


  def self.find installer_name
    # TODO: sanitize installer_name to prevent a query injection attack here
    path = File.join(Configuration.installers_directory, installer_name)
    return nil unless File.directory?(path)
    load_installer(path)
  end


  def self.load_installer dir
    installer = Installer.read( dir, load_config = false )
    installer.path = dir
    return installer
  end


  def initialize dir = Configuration.installers_directory
    @dir = dir
    @list = []
  end


  def load_all
    @list = Dir[ "#{@dir}/*" ].find_all do | child |
      File.directory? child
    end.collect do | child |
      Installers.load_installer child
    end
    return self
  end


  def checkout_local_copy installer
    work_dir = File.join( installer.path, 'work' )
    FileUtils.mkdir_p work_dir
    installer.source_control.checkout work_dir
  end


  def << installer
    if @list.include?( installer )
      raise "installer named #{ installer.name.inspect } already exists"
    end
    begin
      @list << installer
      save_installer installer
      checkout_local_copy installer
      write_config_example installer
      self
    rescue
      FileUtils.rm_rf "#{ @dir }/#{ installer.name }"
      raise
    end
  end


  def save_installer installer
    installer.path = File.join( @dir, installer.name )
    FileUtils.mkdir_p installer.path
  end


  def write_config_example installer
    lucie_config_example = File.join( RAILS_ROOT, 'config', 'lucie_config.rb_example' )
    lucie_config_in_subversion = File.join( installer.path, 'work', 'lucie_config.rb' )
    lucie_config = File.join( installer.path, 'lucie_config.rb' )
    if File.exists?( lucie_config_example ) and not File.exists?( lucie_config_in_subversion )
      FileUtils.cp lucie_config_example, lucie_config
    end
  end


  # delegate everything else to the underlying @list
  def method_missing method, *args, &block
    @list.send method, *args, &block
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
