require 'rubygems'
require 'bundler/setup'
require 'open-uri'
require 'rack'
require 'rack/request'
require 'rack/mock'
require 'rack/test'
require 'rnotifier'

require File.dirname(__FILE__) + "/fixtures/fake_app"

RSpec.configure do |config|
  config.color_enabled = true
  #config.tty = true
  #config.formatter = :documentation
  config.include Rack::Test::Methods

  def app
    Rack::Lint.new(RnotifierTest::FakeApp.new)
  end
end
#ENV['RACK_ENV'] = 'test'

$:.unshift(File.dirname(__FILE__) + '/../lib/')

def rnotifier_init
  ENV['RACK_ENV'] = 'test'
  Rnotifier.load_config("#{Dir.pwd}/spec/fixtures/rnotifier.yaml")
end

def stub_faraday_request(opts = {})
  opts[:status] ||= 200
  opts[:message] ||= 'ok'
  opts[:path] = '/' + [ Rnotifier::Config::DEFAULT[:api_version], Rnotifier::Config::DEFAULT[:notify_path], 'API-KEY'].join('/')

  stubs = Faraday::Adapter::Test::Stubs.new
  conn  = Faraday.new do |builder|
    builder.adapter :test, stubs
  end
  stubs.post(opts[:path]) {|env| [opts[:status], {}, opts[:message]] }

  Rnotifier::Notifier.instance_variable_set('@connection', conn)
  stubs
end

def mock_exception
  begin
    1 + '2'
  rescue Exception => e
    return e
  end
end

