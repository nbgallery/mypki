# there are some jruby configurations that must be
# made before openssl is loaded
require 'mypki/jruby' if RUBY_PLATFORM == 'java'
require 'mypki/core'
require 'mypki/adapters/openssl'
