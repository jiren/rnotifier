ENV['RACK_ENV'] = 'test'
ENV['RN_DEBUG'] = 'true'

require 'rubygems'
require 'bundler/setup'
require 'json'
require 'open-uri'
require 'rack'
require 'rack/request'
require 'rack/mock'
require 'rack/test'
require 'simplecov'
require 'coveralls'

SimpleCov.start do
  add_filter '/spec/'
end

Coveralls.wear!

$:.unshift(File.dirname(__FILE__) + '/../lib/')

require 'rnotifier'
require 'rnotifier/config_test'

Dir['spec/support/*.rb', 'spec/fixtures/*.rb'].each do |f|
  require File.expand_path(f)
end

RSpec.configure do |config|
  config.color_enabled = true
  #config.tty = true
  #config.formatter = :documentation
  config.include Rack::Test::Methods
  config.include RnotifierHelper
  config.include MockExceptions

  def app
    Rack::Lint.new(RnotifierTest::TestSinatraApp.new)
  end

  config.after(:suite) do
    ENV.delete('TEST_DEBUG')
  end

end
