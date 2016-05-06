require 'mypki/core'
require 'net/https'

class Net::HTTP
  alias :old_initialize :initialize

  def initialize *args, &block
    old_initialize *args, &block
    context = MyPKI::Context.new
    
    SSL_ATTRIBUTES.each do |method|
      if [context,self].all? {|o| o.respond_to? method}
        if value = context.send(method)
          send "#{method}=", value
        end
      end
    end
  end
end