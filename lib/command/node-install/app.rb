require "lucie/utils"
require "command/app"
require "configuration"
require "environment"
require "installer"
require "installers"
require "mandatory_option_error"
require "node"
require "nodes"
require "ssh"
require "super-reboot"


module Command
  module NodeInstall
    class App < Command::App
      include Lucie::Utils


      def initialize argv = ARGV, messenger = nil, interfaces = nil
        super argv, messenger
        @interfaces = interfaces
      end


      def main node_name
        start_lucie_logger
        create_installer
        node = load_node( node_name )
        start_html_logger node
        Environment::Install.new( debug_options, @messenger ).start( node, @installer, @interfaces ) do
          install_parallel node
        end
      end


      ##########################################################################
      private
      ##########################################################################


      def start_lucie_logger
        Lucie::Log.path = File.join( Configuration.log_directory, "node-install.log" )
        Lucie::Log.verbose = @verbose
        Lucie::Log.info "Lucie installer started."
      end


      def create_installer
        @installer = Installer.new
        @installer.http_proxy = @options.http_proxy if @options.http_proxy
        @installer.package_repository = @options.package_repository if @options.package_repository
        @installer.suite = @options.suite if @options.suite
        Installers.add @installer, debug_options, @messenger
      end


      def start_html_logger node
        @html_logger = Lucie::Logger::HTML.new( debug_options, @messenger )
        install_option = { :suite => @installer.suite, :ldb_repository => @options.ldb_repository,
          :package_repository => @installer.package_repository, :http_proxy => @installer.http_proxy }
        @html_logger.start install_option
      end


      def install_parallel node
        log_directory = Lucie::Logger::Installer.new_log_directory( node, debug_options, @messenger )
        logger = Lucie::Logger::Installer.new( log_directory, @dry_run )
        install node, logger
        log_installation_success node
      end


      def install node, logger
        reboot node
        start_installer_for node, logger
      end


      def reboot node
        reboot_options = { :script => @options.reboot_script, :ssh => true, :manual => true }
        SuperReboot.new( @html_logger, { :verbose => @options.verbose, :dry_run => @options.dry_run }, @messenger ).start_first_stage node, reboot_options
      end


      def start_installer_for node, logger
        @installer.start node, @options.linux_image, @options.storage_conf, logger, @html_logger, debug_options, @messenger
      end


      def load_node node_name
        node = Node.new( node_name, node_options )
        Nodes.add node, debug_options, @messenger
        Nodes.find node_name
      end


      def node_options
        { :ip_address => @options.address, :netmask_address => @options.netmask,
          :mac_address => @options.mac, :eth1 => @options.eth1, :eth2 => @options.eth2, :eth3 => @options.eth3, :eth4 => @options.eth4 }
      end


      ##########################################################################
      # Logging
      ##########################################################################


      def log_installation_success node
        info "Node '#{ node.name }' installed."
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End: