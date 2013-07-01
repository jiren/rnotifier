$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe Rnotifier::Config do
  before(:all) do
    @api_key = 'API-KEY'
    @notification_path = '/' + [ Rnotifier::Config::DEFAULT[:api_version], 
                                 Rnotifier::Config::DEFAULT[:notify_path], 
                                 @api_key].join('/')
  end

  before(:each) do
    ENV['RACK_ENV'] = @environments = 'production'

    Rnotifier.config do |c|
      c.api_key = @api_key
      #c.environments = @environments
    end
  end

  after(:each) do
    ENV['RACK_ENV'] = 'test'
  end

  it 'has default config values' do
    Rnotifier::Config.tap do |c|
      expect(c.current_env).to eq @environments
      expect(c.notification_path).to eq @notification_path
      expect(c.api_key).to eq @api_key
    end
  end

  it 'is invalid if config environments not include current env' do
    ENV['RACK_ENV'] = 'staging'
    Rnotifier.config{|c| c.environments = 'production'}
    expect(Rnotifier::Config.valid?).to be_false
  end

  it 'is valid if config environments set to test or development' do
    ['test', 'development'].each do |e|
      ENV['RACK_ENV'] = e
      Rnotifier.config{|c| c.environments = e}
      expect(Rnotifier::Config.valid?).to be_true
    end
  end

  it 'is invalid if api key blank' do
    Rnotifier.config{|c| c.api_key = nil}
    expect(Rnotifier::Config.valid?).to be_false
  end

  it 'is load config from the yaml file' do
    Rnotifier.load_config("#{Dir.pwd}/spec/fixtures/rnotifier.yaml")

    expect(Rnotifier::Config.api_key).to eq @api_key
    expect(Rnotifier::Config.environments).to eq ['production', 'staging']
    expect(Rnotifier::Config.valid?).to be_true
  end

end
