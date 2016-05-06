require 'openssl'
require 'mypki/core'

class OpenSSL::SSL::SSLContext
  def self.new
    MyPKI::Context.new
  end
end