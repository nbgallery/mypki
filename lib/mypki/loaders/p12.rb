require 'retriable/core_ext/kernel'

module MyPKI
  class P12
    include Prompter
    include Configuration::Loader
  
    def configure config, path
      if path.end_with? '.p12' or path.end_with? '.pfx'
        config['p12'] = { 'path' => path }
      end
    end
  
    def load config
      if config['p12']
        p12 = File.read config['p12']['path']
        
        begin 
          retriable do
            password = config['p12']['password']
            password ||= pass_prompt 'Enter P12 pass phrase:'
            pki = OpenSSL::PKCS12.new(p12, password)
            Instance.key, Instance.cert = pki.key, pki.certificate
          end
        rescue OpenSSL::PKCS12::PKCS12Error
          fail "Error: bad password"
        end
      end
    end
  end
end
