require 'retriable/core_ext/kernel'

module MyPKI
  module Prompter
    def prompter 
      if defined? IRuby and defined? IRuby::VERSION
        require 'mypki/prompters/iruby'
        @prompter = IRubyPrompter.new
      elsif RUBY_PLATFORM == 'java'
        require 'mypki/prompters/jruby'
        @prompter = JRubyPrompter.new
      else
        require 'mypki/prompters/cli'
        @prompter = CommandLinePrompter.new
      end
    end
    
    def file_prompt prompt, required: true
      file = prompter.file_prompt(prompt)

      if file.nil? or file.empty?
        required ? fail('cancelled') : nil
      else
        expanded = File.expand_path file.strip
                
        if File.directory? expanded
          fail "'#{expanded}' is a directory"
        end
        
        unless File.readable? expanded
          fail "Cannot read '#{expanded}'"
        end
        
        expanded
      end
    end    
    
    def pass_prompt prompt
      pass = prompter.pass_prompt(prompt)
      pass.strip if pass
    end
  end
end