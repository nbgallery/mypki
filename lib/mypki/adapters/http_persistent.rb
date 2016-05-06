require 'net/http/persistent'

class Net::HTTP::Persistent
  alias :old_initialize :initialize

  def initialize *args
    old_initialize *args
    context = MyPKI::Context.new
    self.private_key = context.key
    self.certificate = context.cert
    self.verify_mode = context.verify_mode
  end
end