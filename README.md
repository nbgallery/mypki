# MyPKI

PKI-enables Ruby's OpenSSL libraries, which PKI-enables most libraries and gems written in Ruby.

## Installation 

```
 $ gem install mypki 
```

## Usage

Simply `require 'mypki'` at the top of your script. If you don't want to PKI-enable everything, see the *Adapters* section.

## Configuration

By default, MyPKI saves PKI information in the `.mypki`. Passwords are never saved to the configuration. If a configuration does not exist, MyPKI will prompt you for your PKI path the first time it is run. Should you need to change things, run the mypki utility:

```
$ mypki --reconfigure
```

MyPKI support P12s, PEMs, and key pairs. The P12 loader supports a `password` field in it's section of the ~/.mypki configuration file. I don't recommend keeping your password in the MyPKI config file. 

## Headless configuration 

If you are using MyPKI on a server, then you can specify the location of the MyPKI configuration file by setting the `MYPKI_CONFIG` environment variable.

## The MyPKI Utility

MyPKI ships with a command-line utility that will PKI-enable any other command-line tool written in Ruby. For example, to PKI the `geminabox` uploader:

```
$ mypki gem inabox my-gem-1.0.0.gem
```

IF you do this often, you can alias a command like this:

```
alias gem='mypki gem'
```

## Adapters

By default, MyPKI PKI-enables all OpenSSL contexts. If you would only like to PKI-enable a particular library, you can use an adapter. For example:

```ruby
require 'mypki/adapters/httpclient'
```

The following adapters are available:

* httpclient
* http_persistent
* net_http
* openssl (default)

## How does MyPKI work?

MyPKI modifies `OpenSSL::SSL::SSLContext` to use your PKCS#12 certificate and key. If you're working in a context where you want to be specific about what is PKI-enabled, you can. Here's an example of using my PKI to PKI-enable only `HTTPClient`.

```ruby
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
```

## A note about PEMs

If you're trying to configure with PEM and are getting errors, make sure that your client certificates (and **only** your client certificates) are included in your PEM. For example:

```
$ openssl pkcs12 -in pki.p12 -clcerts -out pki.pem
```
