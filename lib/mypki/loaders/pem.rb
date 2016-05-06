require 'retriable/core_ext/kernel'

module MyPKI
  class PEM
    include Prompter
    include Configuration::Loader
    
    def configure config, path
      if %w[pem id_rsa key crt cert].any? {|ext| path.end_with? ext}
        contents = File.read path
        config['pem'] = {}
        has_cert = false
        
        if contents['PRIVATE KEY']
          config['pem']['path'] = path
        end

        if contents['BEGIN CERTIFICATE']
          has_cert = true
        end

        if config['pem']['path']
          unless has_cert
            config['pem']['cert'] = file_prompt('Path to your certificate: ')
          end
        elsif has_cert
          config['pem']['cert'] = path
          config['pem']['path'] = file_prompt('Path to your private key: ')
        end
      end
    end
    
    def load config 
      if config['pem']
        pem = File.read config['pem']['path']
        cert = (config['pem']['cert'])? File.read(config['pem']['cert']) : pem
        
        begin 
          Instance.cert = OpenSSL::X509::Certificate.new cert
        rescue OpenSSL::X509::CertificateError
          config['pem'] = {}
          Instance.key = Instance.cert = nil
          fail "No certificate found! Regenerate with --nocerts or provide a .key and .crt file separately."
        end
        
        begin 
          retriable do 
            if pem['ENCRYPTED']
              password = pass_prompt('PEM Passphrase:')
              Instance.key = OpenSSL::PKey::RSA.new pem, password
            else
              Instance.key = OpenSSL::PKey::RSA.new pem
            end
          end
        rescue OpenSSL::PKey::RSAError
          fail "Error: bad password"
        end
      end
    end
  end
end
