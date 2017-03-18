require 'set'
require 'metaid'
require 'openssl'

require 'mypki/version'
require 'mypki/prompter'
require 'mypki/configuration'

require 'mypki/loaders/p12'
require 'mypki/loaders/pem'
require 'mypki/loaders/ca'
require 'mypki/loaders/ssh'

module MyPKI
  Instance = OpenSSL::SSL::SSLContext.new 

  Instance.instance_eval do 
    @verify_mode = OpenSSL::SSL::VERIFY_NONE
    @immutable_attributes = [:verify_mode].to_set

    meta_eval do
      define_method(:initialize_copy){|*a|}

      (instance_methods - methods).each do |method|
        if method['=']
          getter, setter = method[0..-2].to_sym, method
          alias_method :"original_#{setter}", setter
          
          # keep track of set attributes
          define_method setter do |*args, &block|
            @immutable_attributes << getter
            send :"original_#{setter}", *args, &block
          end
        end
      end
    end
  end
  
  class Context
    def self.new **options
      if Instance.key.nil? or Instance.cert.nil?
        Configuration.new ENV['MYPKI_CONFIG']||'~/.mypki', **options
      end
    
      context = Instance.clone
      
      context.instance_eval do
        # make immutable attributes immutable
        @immutable_attributes.each do |getter|
          meta_def("#{getter}=") {|*a,&b| send getter}
        end
        
        # don't allow set_params to bypass setters
        meta_def :set_params do |params|
          params.each {|k,v| send "#{k}=", v}
        end
      end
      
      context
    end
  end

  module_function 

  def init reconfigure: false, **options
    if reconfigure
      path = File.expand_path(ENV['MYPKI_CONFIG'] || '~/.mypki')
      File.delete path if File.exist? path
    end
    
    Context.new **options; true
  end

  def dn(flags=nil)
    init
    Instance.cert.subject.to_s(flags)
  end
end
