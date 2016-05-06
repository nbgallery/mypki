require 'fileutils'
require 'shellwords'

module MyPKI
  class SSH
    include Prompter
    include Configuration::Loader
  
    def initialize options
      super options
      
      if options[:ssh]
        Prompter.send :alias_method, :original, :pass_prompt
        Prompter.send(:define_method, :pass_prompt) do |*a| 
          options[:password] = original *a
        end
      end
    end
    
    def load config
      if options[:ssh] and Instance.cert and Instance.key
        ssh_path = File.expand_path '~/.ssh/'
        FileUtils.mkdir ssh_path unless File.exist? ssh_path
        FileUtils.chmod 0700, ssh_path
        
        key_path = File.expand_path '~/.ssh/id_rsa'
        pub_path = File.expand_path '~/.ssh/id_rsa.pub'
        authorized_keys = File.expand_path '~/.ssh/authorized_keys'
        
        if password = options.delete(:password)
          pass = Shellwords.escape password
          result = `echo "#{Instance.key.to_pem}" | \
          openssl pkcs8 -topk8 -out #{key_path} -v2 des3 -passout pass:#{pass} 2>&1`
        else
          result = `echo "#{Instance.key.to_pem}" | \
          openssl pkcs8 -topk8 -out #{key_path} -v2 des3 -nocrypt 2>&1`
        end
        
        fail result unless result.empty?
        FileUtils.chmod 0600, key_path
        
        if password
          `ssh-keygen -f #{key_path} -y -P #{pass} > #{pub_path}`
        else
          `ssh-keygen -f #{key_path} -y > #{pub_path}`
        end
        
        FileUtils.cp pub_path, authorized_keys 
      end
    end
  end
end
