require 'shellwords'

module MyPKI
  module Prompter
    class IRubyPrompter
      def file_prompt prompt

        if prompt['PKI']
          title = 'Configure MyPKI'
          prompt = 'Your script requires access to a PKI-enabled resource. Please select the PKI certificate you would like to use to access that resource.'
          label = :certificate

        elsif prompt['certificate']
          title = 'Missing Certificate'
          prompt = "You're missing a certificate. If you have a certificate to go with your key, upload it below. Press Cancel to start over."
          label = :certificate

         elsif prompt['private key']
          title = 'Missing Private Key'
          prompt = "You're missing a private key. If you have a private key to go with your certificate, upload it below. Press Cancel to start over."
          label = :private_key

        elsif prompt['CA']
          title = 'Add Trust Chains (Optional)'
          prompt = 'Please select the trust chain you would like to use to authenticate servers. Hit cancel if you do not want to verify servers.'
          label = :chains
          
        else
          abort "IRuby integration is missing a corresponding graphical prompt for '#{prompt}'"
        end

        iruby_file_prompt title, prompt, label
      end
      
      def pass_prompt prompt
        response = IRuby.popup 'PKI Password' do 
          password
          cancel
          button
        end
        response[:password] if response
      end

      private 

      def iruby_file_prompt title, prompt, label
        response = IRuby.popup title do 
          text prompt
          html { br; br }
          file label
          cancel
          button
        end
        
        if response && response[label]
          filename = File.join(Dir.home, ".#{response[label][:name]}")
          File.write(filename, response[label][:data])
          
          if RUBY_PLATFORM['cygwin']
            win_path = `cygpath -d #{Shellwords.escape(filename)}`.strip
            `ATTRIB +H  #{win_path.gsub("\\", "\\\\")}`
          end
          
          filename
        end
      end
    end
  end
end
