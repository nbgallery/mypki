module MyPKI
  module Prompter
    class CommandLinePrompter
      def file_prompt prompt
        require 'readline'
        Readline.completion_append_character = ''
        
        Readline.completion_proc = proc do |key|
          path = File.expand_path key
          path += '/' if key.end_with? '/'
          Dir["#{path}*"]
        end
        
        Readline.readline(prompt, true)
      end
    
      def pass_prompt prompt
        require 'highline/import'
        ask("#{prompt} ") {|q| q.echo = false}
      end
    end
  end
end