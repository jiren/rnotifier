require 'socket'
require 'yaml'
require 'digest/md5'
require 'multi_json'
require 'faraday'

require 'rnotifier/version'
require 'rnotifier/config'
require 'rnotifier/rlogger'
require 'rnotifier/notifier'
require 'rnotifier/exception_data' 
require 'rnotifier/event_data' 
require 'rnotifier/rack_middleware'
require 'rnotifier/parameter_filter'
require 'rnotifier/exception_code'
require 'rnotifier/railtie' if defined?(Rails)
require 'rnotifier/benchmark'

module Rnotifier
  class << self
    def config(&block)
      yield(Rnotifier::Config) if block_given?
      Rnotifier::Config.init
    end

    def load_config(file)
      config_yaml = YAML.load_file(file)

      self.config do |c|
        c.api_key = config_yaml['apikey'] 

        ['environments', 'api_host', 'ignore_exceptions', 'ignore_bots', 'capture_code'].each do |f|
          c.send("#{f}=", config_yaml[f]) if config_yaml[f]
        end
      end
    end

    def context(attrs = {})
      if Thread.current[:rnotifier_context] 
        Thread.current[:rnotifier_context].merge!(attrs)
      else
        Thread.current[:rnotifier_context] = attrs
      end
    end

    def clear_context
      Thread.current[:rnotifier_context] = nil
    end

    def exception(exception, params = {})
      Rnotifier::ExceptionData.new(exception, params, {:type => :rescue}).notify
    end

    def event(name, params, tags = {})
      if Rnotifier::Config.valid? && params.is_a?(Hash)
        Rnotifier::EventData.new(name, Rnotifier::EventData::EVENT, params, tags[:tags]).notify 
      end
    end

    def alert(name, params, tags = {})
      if Rnotifier::Config.valid? && params.is_a?(Hash)
        Rnotifier::EventData.new(name, Rnotifier::EventData::ALERT, params, tags[:tags]).notify 
      end
    end

  end
end
