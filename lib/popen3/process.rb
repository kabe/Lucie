module Popen3
  class Process
    #
    # Creates a new Popen3::Popen3 object.
    #
    def initialize
      @child, @parent = init_pipes
    end


    #
    # Waits for and returns the pid of the subprocess.
    #
    def wait
      ::Process.wait @pid
    end


    #
    # Executes command as subprocess. Standard out and error from
    # the subprocess are passed as block arguments.
    #
    def popen3 command, env = {}, &block
      @pid = fork_child( command, env )
      # Parent process
      close @parent
      begin
        yield child_stdout, child_stderr
      ensure
        close @child
      end
    end


    ############################################################################
    private
    ############################################################################


    def fork_child command, env
      Kernel.fork do
        close @child
        redirect_child_io
        start_child command, env
      end
    end


    def redirect_child_io
      STDIN.reopen @parent[ :stdin ]
      STDOUT.reopen @parent[ :stdout ]
      STDERR.reopen @parent[ :stderr ]
      close @parent
    end


    def start_child command, env
      env.each_pair do | key, value |
        ENV[ key ]= value
      end
      Kernel.exec command
    end


    def child_stdout
      @child[ :stdout ]
    end


    def child_stderr
      @child[ :stderr ]
    end


    def close pipes
      pipes.each do | name, pipe |
        unless pipe.closed?
          pipe.close
        end
      end
    end


    def init_pipes
      rd_stdin, wr_stdin = IO.pipe
      rd_stdout, wr_stdout = IO.pipe
      rd_stderr, wr_stderr = IO.pipe
      [ { :stdin => wr_stdin, :stdout => rd_stdout, :stderr => rd_stderr },
        { :stdin => rd_stdin, :stdout => wr_stdout, :stderr => wr_stderr } ]
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End: