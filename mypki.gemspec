# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mypki/version'

Gem::Specification.new do |spec|
  spec.name          = "mypki"
  spec.version       = MyPKI::VERSION
  spec.authors       = ["Kyle King"]
  spec.email         = ["kylejking@gmail.com"]

  spec.summary       = %q{PKI-enable Ruby}
  spec.description   = %q{PKI-enables Ruby's OpenSSL libraries, which PKI-enables most libraries and gems written in Ruby.}
  spec.homepage      = "https://github.com/jupyter-gallery/mypki"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'multi_json'
  spec.add_dependency 'optimist'
  spec.add_dependency 'metaid'
  spec.add_dependency 'highline'
  spec.add_dependency 'retriable'

  spec.add_development_dependency "pry"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
