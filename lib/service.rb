class Service
  @@prerequisites = {}


  def self.check_prerequisites options
    missings = []
    ObjectSpace.each_object( Class ) do | klass |
      next if klass.superclass != self
      missings += check_prerequisite( klass, options )
    end
    unless missings.empty?
      raise "#{ missings.sort.join( ', ' ) } not installed. Try 'aptitude install #{ missings.sort.join( ' ' ) }'"
    end
  end


  def self.check_prerequisite service, options
    missings = []
    return missings unless @@prerequisites[ service ]
    messenger = options[ :messenger ] || $stderr
    @@prerequisites[ service ].each do | each |
      messenger.print "Checking #{ each } ... "
      if FileTest.exist?( "/var/lib/dpkg/info/#{ each }.md5sums" )
        messenger.puts "INSTALLED"
      else
        missings << each unless options[ :dry_run ]
        messenger.puts "NOT INSTALLED"
      end
    end
    missings
  end


  def self.prerequisite package
    module_eval do | service |
      @@prerequisites[ service ] ||= []
      @@prerequisites[ service ] << package
    end
  end


  def self.config path
    module_eval %-
      @@config = path
    -
  end


  def initialize debug_options
    @debug_options = debug_options
  end


  ##############################################################################
  private
  ##############################################################################


  def restart
    instance_eval do | obj |
      prerequisites = obj.class.__send__( :class_variable_get, :@@prerequisites )[ obj.class ]
      prerequisites.each do | each |
        script = "/etc/init.d/#{ each }"
        if @debug_options[ :dry_run ] || FileTest.exists?( script )
          run "sudo #{ script } restart", @debug_options, @debug_options[ :messenger ]
        end
      end
    end
  end


  def backup
    instance_eval do | obj |
      config = obj.class.__send__( :class_variable_get, :@@config )
      if @debug_options[ :dry_run ] || FileTest.exists?( config )
        run "sudo mv -f #{ config } #{ config }.old", @debug_options, @debug_options[ :messenger ]
      end
    end
  end
end


require "service/approx"
require "service/debootstrap"
require "service/dhcp"
require "service/installer"
require "service/nfs"
require "service/tftp"


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
