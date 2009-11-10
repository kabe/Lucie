require "English"


module Popen3
  class Shell
    #
    # Calls the block passed as an argument with a new Popen3::Shell object.
    #
    # _Example:_
    #  Popen3::Shell.open do | shell |
    #    # Add some hooks here
    #    shell.on_...
    #    shell.on_...
    #      ...
    #
    #    # Finally spawn a subprocess
    #    shell.exec command
    #  end
    #
    def self.open &block
      block.call self.new
    end


    #
    # Returns the status code of the subprocess. The status code
    # encodes both the return code of the process and information
    # about whether it exited using the exit() or died due to a
    # signal. Functions to help interpret the status code are defined
    # in Process::Status class.
    #
    def child_status
      $CHILD_STATUS
    end


    #
    # Registers a block that is called when the subprocess outputs a
    # line to standard out.
    #
    def on_stdout &block
      @on_stdout = block
    end


    #
    # Registers a block that is called when the subprocess outputs a
    # line to standard error.
    #
    def on_stderr &block
      @on_stderr = block
    end


    #
    # Registers a block that is called when the subprocess exits.
    #
    def on_exit &block
      @on_exit = block
    end


    #
    # Registers a block that is called when the subprocess exits
    # successfully.
    #
    def on_success &block
      @on_success = block
    end


    #
    # Registers a block that is called when the subprocess exits
    # abnormally.
    #
    def on_failure &block
      @on_failure = block
    end


    #
    # Spawns a subprocess with specified environment variables.
    #
    def exec command, env = {}
      process = Process.new
      process.popen3( command, env ) do | stdout, stderr |
        handle_child_output stdout, stderr
      end
      process.wait
      handle_exitstatus
    end


    ############################################################################
    private
    ############################################################################


    def handle_child_output stdout, stderr
      tout = create_output_handler_thread_for( stdout ) do | line |
        do_stdout line
      end
      terr = create_output_handler_thread_for( stderr ) do | line |
        do_stderr line
      end
      tout.join
      terr.join
    end


    def create_output_handler_thread_for io, &block
      t = Thread.new do
        while line = io.gets do
          block.call line.chomp
        end
      end
      t.priority = -10
      t
    end


    # run hooks ################################################################


    def handle_exitstatus
      do_exit
      if child_status.exitstatus == 0
        do_success
      else
        do_failure
      end
    end


    def do_stdout line
      if @on_stdout
        @on_stdout.call line
      end
    end


    def do_stderr line
      if @on_stderr
        @on_stderr.call line
      end
    end


    def do_failure
      if @on_failure
        @on_failure.call
      end
    end


    def do_success
      if @on_success
        @on_success.call
      end
    end


    def do_exit
      if @on_exit
        @on_exit.call
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
