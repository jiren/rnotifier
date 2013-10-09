require 'socket'
require 'thread'
require 'yaml'
require 'digest/md5'
require 'yajl'
require 'faraday'

require 'rnotifier/version'
require 'rnotifier/config'
require 'rnotifier/rlogger'
require 'rnotifier/notifier'
require 'rnotifier/exception_data' 
require 'rnotifier/message' 
require 'rnotifier/rack_middleware'
require 'rnotifier/parameter_filter'
require 'rnotifier/exception_code'
require 'rnotifier/railtie' if defined?(Rails)
require 'rnotifier/benchmark'
require 'rnotifier/benchmark/core_ext'
require 'rnotifier/benchmark/benchmark_proxy'
require 'rnotifier/benchmark/benchmark_view'
require 'rnotifier/rails/benchmark_filters'
require 'rnotifier/message_store'

module Rnotifier

  class RnotifierException < Exception; end

  class << self
    def config(&block)
      yield(Rnotifier::Config) if block_given?
      Rnotifier::Config.init
    end

    def load_config(file)
      config_yaml = YAML.load_file(file)

      self.config do |c|
        c.api_key = config_yaml['apikey'] 
        c.app_id  = config_yaml['app_id']

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
      request = (params.delete(:request)|| params.delete('request'))

      if request 
        self.context(params)
        Rnotifier::ExceptionData.new(exception, request, params.merge(:type => :rack)).notify
      else
        Rnotifier::ExceptionData.new(exception, params).notify
      end
    end

    def alert(name, params, tags = {})
      raise RnotifierException.new('params must be a Hash') unless params.is_a?(Hash)
      Rnotifier::Message.new(name, Rnotifier::Message::ALERT, params, tags[:tags]).notify 
    end

    def event(name, params, tags = {})
      raise RnotifierException.new('params must be a Hash') unless params.is_a?(Hash)
      Rnotifier::Message.new(name, Rnotifier::Message::EVENT, params, tags[:tags]).enq
    end

    def benchmark(bm_name, opts = {}, &block)
      Rnotifier::Benchmark.it(bm_name, opts, &block)
    end

  end
end
