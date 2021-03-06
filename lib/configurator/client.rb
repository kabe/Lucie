require "confidential-data-client"
require "lucie/logger"
require "scm"
require "ssh"


class Configurator
  class Client
    attr_writer :ssh


    BASE_DIRECTORY = "/var/lib/lucie"
    REPOSITORY = "/var/lib/lucie/ldb"
    REPOSITORY_BASE_DIRECTORY = "/var/lib/lucie/config"


    def self.guess_scm node, debug_options = {}
      return "DUMMY_SCM" if debug_options[ :dry_run ]
      ssh = SSH.new( debug_options )
      ssh.sh( node.ip_address, "ls -1 -d #{ File.join( REPOSITORY, '.*' ) }" ).split( "\n" ).each do | each |
        case File.basename( each )
        when ".hg"
          return "Mercurial"
        when ".svn"
          return "Subversion"
        when ".git"
          return "Git"
        end
      end
      raise "Cannot determine SCM used on #{ node.name }:#{ REPOSITORY }"
    end


    def initialize scm = nil, debug_options = {}
      @debug_options = debug_options
      @ssh = SSH.new( @debug_options )
      @scm = Scm.from( scm, @debug_options ) if scm
    end


    def install server_ip, client_ip, url, logger = Lucie::Logger::Null.new
      setup client_ip, logger
      install_get_confidential_data client_ip, server_ip
      install_repository client_ip, server_ip, url
    end


    def update client_ip, server_ip
      update_commands( client_ip, server_ip, REPOSITORY ).each do | each |
        SSH.new( @debug_options ).sh_a client_ip, each
      end
    end


    def update_symlink url, client_ip
      @ssh.sh client_ip, "rm -f /var/lib/lucie/ldb"
      @ssh.sh client_ip, "ln -s #{ repository_directory_from( url ) } /var/lib/lucie/ldb"
    end


    def start ip, logger = Lucie::Logger::Null.new    
      SSH.new( @debug_options.merge( :logger => logger ) ).sh_a ip, "cd #{ scripts_directory } && eval \\`#{ ldb_command } env\\` && make"
    end


    ############################################################################
    private
    ############################################################################


    # Paths ####################################################################


    def repository_directory_from url
      File.join REPOSITORY_BASE_DIRECTORY, Configurator.repository_name_from( url )
    end


    def scripts_directory
      File.join REPOSITORY, "scripts"
    end


    def ldb_command
      File.join REPOSITORY, "bin", "ldb"
    end


    # Client-side operations ###################################################


    def setup client_ip, logger
      unless repository_base_directory_exists?( client_ip )
        create_repository_base_directory client_ip
      end
    end


    def create_repository_base_directory client_ip
      @ssh.sh client_ip, "mkdir -p #{ REPOSITORY_BASE_DIRECTORY }"
    end


    def install_get_confidential_data client_ip, server_ip
      ConfidentialDataClient.new( client_ip, server_ip, @debug_options ).install
    end


    def install_repository client_ip, server_ip, url
      SSH.new( @debug_options ).sh_a client_ip, @scm.install_command( REPOSITORY_BASE_DIRECTORY, server_ip, url )
    end


    def update_commands client_ip, server_ip, repository
      @scm.update_commands_for REPOSITORY, server_ip, repository
    end


    def repository_base_directory_exists? ip
      begin
        @ssh.sh ip, "test -d #{ REPOSITORY_BASE_DIRECTORY }"
        true
      rescue
        false
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
