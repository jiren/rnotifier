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

module Rnotifier
  class << self
    def config(&block)
      yield(Rnotifier::Config)
      Rnotifier::Config.init
    end

    def load_config(file)
      config_yaml = YAML.load_file(file)

      self.config do |c|
        c.api_key = config_yaml['apikey'] 

        ['environments', 'api_host', 'ignore_exceptions', 'capture_code'].each do |f|
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

    def event(name, params = {})
      Rnotifier::EventData.new(name, Rnotifier::EventData::EVENT, params).notify if Rnotifier::Config.valid?
    end

    def alert(name, params = {})
      Rnotifier::EventData.new(name, Rnotifier::EventData::ALERT, params).notify if Rnotifier::Config.valid?
    end

  end
end
