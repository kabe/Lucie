#
# network_interfaces.rb - A simple wrapper class for ifconfig.rb
#
# Usage:
#
#   NetworkInterfaces.each do | each |
#     p each.ip_address
#     p each.subnet
#     p each.netmask
#       ...
#   end
#


require 'ifconfig'


class NetworkInterfaces
  ifconfig = IfconfigWrapper.new.parse
  @@interfaces = ifconfig.interfaces.collect do | each |
    interface = ifconfig[ each ]

    def interface.netmask
      networks[ 'inet' ] ? networks[ 'inet' ].mask : nil
    end

    def interface.ip_address
      addresses( 'inet' ) ? addresses( 'inet' ).to_s : nil
    end

    def interface.subnet
      if ip_address and netmask
        return Network.network_address( ip_address, netmask )
      end
    end

    interface
  end


  def self.method_missing method, *args, &block
    @@interfaces.__send__ method, *args, &block
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
