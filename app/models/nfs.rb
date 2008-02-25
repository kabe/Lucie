require 'ftools'
require 'popen3/shell'


class Nfs
  def self.setup installer_name
    self.new.setup installer_name
  end


  attr_reader :installer_name


  def setup installer_name
    @installer_name = installer_name

    File.copy config_file, config_file + '.old'

    File.open( config_file, 'w' ) do | file |
      nodes.each do | each |
        file.puts "#{ nfsroot } #{ each }(async,ro,no_root_squash,no_subtree_check)"
      end
    end

    sh_exec '/etc/init.d/nfs-kernel-server restart'
  end


  # [???] get nfsroot path from other class (Nfsroot or Installers)?
  def nfsroot
    File.expand_path( "#{ RAILS_ROOT }/installers/#{ installer_name }/nfsroot" )
  end


  def nodes
    Nodes.load_enabled( installer_name ).collect do | each |
      each.name
    end
  end


  def config_file
    return '/etc/exports'
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
