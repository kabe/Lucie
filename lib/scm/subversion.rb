class Scm
  class Subversion < Common
    def clone url, target
      run "svn co #{ url } #{ target }", { "SVN_SSH" => "ssh -i #{ SSH::PRIVATE_KEY }" }
    end


    def update_commands_for target, server_ip, repository
      [ "scp #{ SSH::OPTIONS } -p -r #{ whoami }@#{ server_ip }:#{ repository } #{ File.dirname target }" ]
    end


    def update target
      run "cd #{ target } && svn update", { "SVN_SSH" => "ssh -i #{ SSH::PRIVATE_KEY }" }
    end


    def install_command target, server_ip, url
      "scp #{ SSH::OPTIONS } -p -r #{ whoami }@#{ server_ip }:#{ Configurator::Server.clone_directory( url ) } #{ target }"
    end


    def to_s
      "Subversion"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
