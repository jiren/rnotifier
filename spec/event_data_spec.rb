$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe Rnotifier::EventData do

  before(:all) do
    rnotifier_init
    @name = 'product'
    @data = {:id => 1, :name => 'ProductX'}
  end

  it 'is initialize event_data object' do
    [:event, :alert].each do |e|
      e_data = Rnotifier::EventData.new(@name, e, @data)

      expect(e_data.data[:name]).to eq @name
      expect(e_data.data[:data]).to eq @data
      expect(e_data.data[:type]).to eq e
    end
  end

  it 'sends event data to server' do
    path = '/' + [ Rnotifier::Config::DEFAULT[:api_version], Rnotifier::Config::DEFAULT[:event_path], 'API-KEY'].join('/')
    stubs = stub_faraday_request({:path => path})

    Rnotifier::EventData.new(@name, @data).notify

    expect { stubs.verify_stubbed_calls }.to_not raise_error
  end

end
