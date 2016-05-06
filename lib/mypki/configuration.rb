require 'multi_json'

module MyPKI
  class Configuration < Hash
    include Prompter
    attr_reader :options
  
    def initialize path, **options
      @options = options
      @path = File.expand_path path
      @loaders = loaders.map{|loader| loader.new options}
      
      if File.exist? @path        
        begin 
          merge! MultiJson.load(File.read(@path))
          @loaders.each {|l| l.load self}
        rescue => ex
          raise "Bad MyPKI configuration (#{ex.message})"
        end
      else      
        retriable on_retry: proc { warn $! } do
          clear 
          create
        end
      end
    end
    
    def create
      pki = file_prompt 'Path to your PKI: '
      
      @loaders.each do |loader| 
        loader.configure self, pki
        loader.load self unless options[:no_verify]
      end
      
      if Instance.cert.nil? and Instance.key.nil? and not options[:no_verify]
        fail 'Unknown PKI type - add an extension or try another file'
      end
      
      if File.writable? File.dirname(@path)
        File.write @path, MultiJson.dump(Hash[keys.zip(values)], :pretty => true)
      else
        warn "warning: #{File.dirname(@path)} is not writable! MyPKI will not save a configuration."
      end
    end
    
    class << self
      attr_accessor :loaders
    end
   
    def loaders
      self.class.loaders ||= []
    end
    
    module Loader
      # options passed to MyPKI.init
      attr_reader :options
    
      def initialize options
        @options = options
      end
    
      # once a config is established, it is passed to each loader to load
      # whatever they need
      def load config
      end
      
      # runs during configuration, before anything has been loaded,
      # to give loaders a chance to insert anything they need into the config
      def configure config, path
      end
    
      def self.included klass
        (Configuration.loaders ||= []) << klass
      end
    end
  end
end
