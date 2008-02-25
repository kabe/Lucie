class Nodes
  def self.summary installer_name
    nodes = load_node_list( installer_name )
    if nodes.size == 0
      return 'Never installed'
    else nodes.size > 0
      status = Hash.new( 0 )
      nodes.each do | each |
        status[ each.latest_install.status ] += 1
      end
      summary = []
      if status[ 'failed' ] > 0
        summary << "#{ status[ 'failed' ] } FAIL"
      end
      if status[ 'incomplete' ] > 0
        summary << "#{ status[ 'incomplete' ] } incomplete"
      end
      return 'OK' if summary == []
      return summary.join( ', ' )
    end
  end


  def self.load_node_list installer_name
    load_all.list.select do | each |
      each.installer_name == installer_name
    end
  end


  def self.load_all options = {}
    return Nodes.new( Configuration.nodes_directory ).load_all( options )
  end


  def self.load_enabled installer_name
    Nodes.new( Configuration.nodes_directory ).load_enabled( installer_name )
  end


  def self.path node_name
    File.join( Configuration.nodes_directory, node_name )
  end


  def self.remove! node_name
    unless File.directory?( path( node_name ) )
      raise "Node '#{ node_name }' not found."
    end
    FileUtils.rm_rf path( node_name )
  end


  def self.find node_name
    # TODO: sanitize node_name to prevent a query injection attack here
    unless File.directory?( path( node_name ) )
      return nil
    end
    load_node path( node_name )
  end


  def self.load_node dir, options = {}
    node = Node.read( dir, options )
    return node
  end


  attr_reader :dir
  attr_reader :list


  def initialize dir = Configuration.nodes_directory
    @dir = dir
    @list = []
  end


  def load_enabled installer_name
    @list = Dir[ "#{@dir}/*" ].find_all do | child |
      enabled = Dir[ child + "/*" ].find_all do | each |
        installer_name == File.basename( each )
      end
      ( not enabled.empty? ) and File.directory?( child )
    end.collect do | child |
      Nodes.load_node child
    end
    return self
  end


  def load_all options = {}
    @list = Dir[ "#{ @dir }/*" ].find_all do | child |
      File.directory? child
    end.collect do | child |
      Nodes.load_node child, options
    end
    return self
  end


  def << node
    if @list.include?( node )
      raise "node named #{ node.name.inspect } already exists."
    end
    begin
      @list << node
      save_node node
      write_config node
      self
    rescue
      FileUtils.rm_rf "#{ @dir }/#{ node.name }"
      raise
    end
  end


  def save_node node
    node.path = File.join( @dir, node.name )
    FileUtils.mkdir_p node.path
  end


  def write_config node
    mac_address_config = File.join( node.path, node.mac_address.gsub( ':', '_' ) )

    # FileUtils.touch mac_address_config
    File.open( mac_address_config, 'w' ) do | file |
      file.puts <<-EOF
gateway_address:#{ node.gateway_address }
ip_address:#{ node.ip_address }
netmask_address:#{ node.netmask_address }
EOF
    end
  end


  # delegate everything else to the underlying @list
  def method_missing method, *args, &block
    @list.send method, *args, &block
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
