require 'mypki/prompters/readline'
require 'mypki/jruby/jline-2.12.1.jar'
java_import 'jline.console.ConsoleReader'

module MyPKI
  module Prompter
    class JRubyPrompter < ReadlinePrompter
      def pass_prompt prompt
        ConsoleReader.new.read_line prompt, ' '.ord
      end
    end
  end
end