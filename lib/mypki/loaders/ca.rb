require 'retriable/core_ext/kernel'

module MyPKI
  class CA
    include Prompter
    include Configuration::Loader
    
    DEFAULT_PATH = '/etc/pki/tls/certs/ca-bundle.crt'

    def configure config, path
      if File.readable? DEFAULT_PATH
        config['ca'] = DEFAULT_PATH
      elsif config['ca'].nil?
        prompt = "Path to CA chains (press enter to skip): "
        path = file_prompt prompt, required: false
        
        if path.nil?
          config['ca'] = ''
        else
          if File.directory? path
            fail "'#{path}' is a directory"
          elsif not File.readable? path
            fail "Cannot read '#{path}'"
          else
            config['ca'] = path
          end
        end
      end
    end
    
    def load config
      unless config['ca'].empty?
        Instance.cert_store = OpenSSL::X509::Store.new
        Instance.cert_store.add_file config['ca']
        Instance.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end
    end
  end
end