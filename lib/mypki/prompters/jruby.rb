require 'mypki/prompters/cli'
require 'mypki/jruby/jline-2.14.1.jar'
java_import 'jline.console.ConsoleReader'

module MyPKI
  module Prompter
    class JRubyPrompter < CommandLinePrompter
      def pass_prompt prompt
        ConsoleReader.new.read_line(prompt, ' '.ord)
      end
    end
  end
end