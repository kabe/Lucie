require "lucie/log"


module Lucie
  module IO
    def info message
      Lucie::Log.info message
      stdout.puts message
    end


    def debug message
      Lucie::Log.debug message
      stderr.puts message
    end


    def error message
      Lucie::Log.error message
      stderr.puts message
    end


    def stdout
      messenger || $stdout
    end


    def stderr
      messenger || $stderr
    end


    def messenger
      @debug_options ? @debug_options[ :messenger ] : nil
    end
  end
end
