$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe Rnotifier::ConfigTest do

  after(:each) do
    ENV['RACK_ENV'] = 'test'
  end

  it 'sends test exception exception' do
     rnotifier_init
     stubs = stub_faraday_request

     expect(Rnotifier::ConfigTest.test).to be_true 
     expect {stubs.verify_stubbed_calls }.to_not raise_error
  end

  it 'sends test exception for rnotifier_test env' do

    ['rnotifier_without_env', 'rnotifier'].each do |c|
      stubs = stub_faraday_request

      ENV['RACK_ENV'] = 'rnotifier_test'
      Rnotifier.load_config("#{Dir.pwd}/spec/fixtures/#{c}.yaml")
      Rnotifier::Config.environments = [ENV['RACK_ENV']]
      Rnotifier::Config.init

      expect(Rnotifier::Config.valid?).to be_true
      expect(Rnotifier::ConfigTest.test).to be_true 
      expect {stubs.verify_stubbed_calls }.to_not raise_error
    end
  end

end
