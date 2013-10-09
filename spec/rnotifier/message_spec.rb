require 'spec_helper'

describe Rnotifier::Message do

  before(:all) do
    rnotifier_init
    @name = 'product'
    @data = {:id => 1, :name => 'ProductX'}
  end

  before(:each) do
    Rnotifier::MessageStore.clear rescue ''
  end

  it 'is initialize message object' do
    [Rnotifier::Message::EVENT, Rnotifier::Message::ALERT].each do |e|
      e_data = Rnotifier::Message.new(@name, e, @data)

      expect(e_data.data[:name]).to eq @name
      expect(e_data.data[:data]).to eq @data
      expect(e_data.data[:type]).to eq e
    end
  end

  it 'is initialize message object with tags' do
    [:event, :alert].each do |e|
      e_data = Rnotifier::Message.new(@name, e, @data, [:create, :update])

      expect(e_data.data[:name]).to eq @name
      expect(e_data.data[:data]).to eq @data
      expect(e_data.data[:type]).to eq e
      expect(e_data.data[:tags]).to eq [:create, :update]
    end
  end

  it 'sends event data to server' do
    stubs = stub_faraday_request({:path => Rnotifier::Config.messages_path})
    status = Rnotifier::Message.new(@name, @data).notify

    expect(status).to be_true
    expect { stubs.verify_stubbed_calls }.to_not raise_error
  end

  it 'sends alert with tags to server' do
    stubs = stub_faraday_request({:path => Rnotifier::Config.messages_path})
    status = Rnotifier.alert(@name, @data, {:tags => [:new]})

    expect(status).to be_true
    expect { stubs.verify_stubbed_calls }.to_not raise_error
  end

  it 'enq tag to message store' do
    status = Rnotifier.event(@name, @data, {:tags => [:new]})

    expect(status).to be_true
    expect(Rnotifier::MessageStore.size).to eq 1
  end

  it 'app env should have time zone' do
    env = Rnotifier::Message.app_env
    expect(env[:time_zone]).not_to be_nil
  end

end
