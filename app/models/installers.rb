require 'fileutils'


class Installers
  attr_reader :list


  def self.load_all
    Installers.new( Configuration.installers_directory ).load_all
  end


  def load_all
    @list = Dir[ "#{ @dir }/*" ].find_all do | child |
      File.directory? child
    end.collect do | child |
      Installers.load_installer child
    end
    return self
  end


  def self.load_installer dir
    installer = Installer.read( dir, load_config = false )
    installer.path = dir
    return installer
  end


  def self.find installer_name
    # TODO: sanitize installer_name to prevent a query injection attack here
    path = File.join( Configuration.installers_directory, installer_name )
    unless File.directory?( path )
      return nil
    end
    load_installer path
  end


  def initialize dir = Configuration.installers_directory
    @dir = dir
    @list = []
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


  def sort_by_name
    sorted_list = @list.sort_by do | installer |
      installer.name
    end
    return sorted_list
  end


  # delegate everything else to the underlying @list
  def method_missing method, *args, &block
    @list.send method, *args, &block
  end


  private


  def save_installer installer
    installer.path = File.join( @dir, installer.name )
    FileUtils.mkdir_p installer.path
  end


  def checkout_local_copy installer
    work_dir = File.join( installer.path, 'work' )
    FileUtils.mkdir_p work_dir
    installer.source_control.checkout work_dir
  end


  def write_config_example installer
    lucie_config_example = File.join( RAILS_ROOT, 'config', 'lucie_config.rb_example' )
    lucie_config_in_subversion = File.join( installer.path, 'work', 'lucie_config.rb' )
    lucie_config = File.join( installer.path, 'lucie_config.rb' )
    if File.exists?( lucie_config_example ) and not File.exists?( lucie_config_in_subversion )
      FileUtils.cp lucie_config_example, lucie_config
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
