ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler/setup'
require 'open-uri'
require 'rack'
require 'rack/request'
require 'rack/mock'
require 'rack/test'
require 'simplecov'
require 'coveralls'

SimpleCov.start do
  add_filter '/spec/'
  add_group 'gem', 'lib'
end

Coveralls.wear!

$:.unshift(File.dirname(__FILE__) + '/../lib/')

require 'rnotifier'
require File.dirname(__FILE__) + "/fixtures/fake_app"
require File.dirname(__FILE__) + '/mock_exception_helper' 


RSpec.configure do |config|
  config.color_enabled = true
  #config.tty = true
  #config.formatter = :documentation
  config.include Rack::Test::Methods

  def app
    Rack::Lint.new(RnotifierTest::FakeApp.new)
  end
end

def rnotifier_init
  ENV['RACK_ENV'] = 'test'
  Rnotifier.load_config("#{Dir.pwd}/spec/fixtures/rnotifier.yaml")
end

def stub_faraday_request(opts = {})
  opts[:status] ||= 200
  opts[:message] ||= 'ok'
  opts[:path] ||= '/' + [ Rnotifier::Config::DEFAULT[:api_version], Rnotifier::Config::DEFAULT[:exception_path]].join('/')

  stubs = Faraday::Adapter::Test::Stubs.new
  conn  = Faraday.new do |builder|
    builder.adapter :test, stubs
  end
  stubs.post(opts[:path]) {|env| [opts[:status], {}, opts[:message]] }

  Rnotifier::Notifier.instance_variable_set('@connection', conn)
  stubs
end

def clear_config
  [:api_key, :exception_path, :event_path, :environments, :current_env,
    :app_env, :api_host, :ignore_exceptions, :capture_code].each do |m|
      Rnotifier::Config.send("#{m}=", nil)
    end
end
