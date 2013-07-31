$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe Rnotifier::Config do
  before(:all) do
    @api_key = 'API-KEY'
    @exception_path = '/' + [ Rnotifier::Config::DEFAULT[:api_version], 
                              Rnotifier::Config::DEFAULT[:exception_path]].join('/')

    @event_path = '/' + [ Rnotifier::Config::DEFAULT[:api_version], 
                              Rnotifier::Config::DEFAULT[:event_path]].join('/')
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
      expect(c.exception_path).to eq @exception_path
      expect(c.event_path).to eq @event_path
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
    expect(Rnotifier::Config.environments).to eq ['production', 'staging', 'test']
    expect(Rnotifier::Config.valid?).to be_true
  end

  it 'set config invalid if environments not set in config and app env is test or development' do
    clear_config
    ENV['RACK_ENV'] = 'test'
    
    Rnotifier.load_config("#{Dir.pwd}/spec/fixtures/rnotifier_ignore_env.yaml")

    expect(Rnotifier::Config.valid?).to be_false
  end

  it 'set api key from the ENV variable RNOTIFIER_API_KEY' do
    clear_config
    ENV['RNOTIFIER_API_KEY'] = 'ENV-API-KEY'
    Rnotifier::Config.init

    expect(Rnotifier::Config.api_key).to eq 'ENV-API-KEY'
    ENV['RNOTIFIER_API_KEY'] = nil
  end

end
