require 'mypki/core'
require 'httpclient'

class HTTPClient
  class SSLSocketWrap
    def create_openssl_socket socket
      context = MyPKI::Context.new
      @context.set_context(context)
      ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, context)
    end
  end
end