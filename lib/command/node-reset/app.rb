require "command/app"
require "service"


module Command
  module NodeReset
    class App < Command::App
      def initialize argv = ARGV, debug_options = {}
        @debug_options = debug_options
        super argv, @debug_options
      end


      def main
        Service::Tftp.new( @debug_options ).setup_localboot_all
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
