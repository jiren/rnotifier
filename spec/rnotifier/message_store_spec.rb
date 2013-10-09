require 'spec_helper'

describe Rnotifier::MessageStore do

  before(:all) do
    rnotifier_init
    @name = 'product'
    @data = {:id => 1, :name => 'ProductX'}
  end

  before(:each) do
    Rnotifier::MessageStore.clear rescue ''
    LastRequest.clear
  end

  let(:message_store) { Rnotifier::MessageStore }

  it 'add event to queue' do
    event = Rnotifier::Message.new(@name, Rnotifier::Message::EVENT, @data)
    expect(message_store.size).to be_zero

    Rnotifier::MessageStore.add(event)
    expect(message_store.size).to eq 1
  end

  it 'send data if event queue hit the threshold' do
    stubs = stub_faraday_request({:path => Rnotifier::Config.messages_path})

    2.times do |i| 
      data = {:id => i + 1, :name => "Product #{i+1}"}
      Rnotifier::MessageStore.add(Rnotifier::Message.new(@name, Rnotifier::Message::BENCHMARK, data))
    end

    sleep(0.5)

    messages = LastRequest.env[:body]['messages']
    expect(messages.length).to eq 2

    expect { stubs.verify_stubbed_calls }.to_not raise_error
    expect(message_store.size).to be_zero
  end

  it 'send data by auto sender thread if time limit exceed by auto send time limit' do
    message_store.start_auto_sender

    stubs = stub_faraday_request({:path => Rnotifier::Config.messages_path})

    Rnotifier::MessageStore.add(Rnotifier::Message.new(@name, Rnotifier::Message::BENCHMARK, @data))

    sleep(3)

    request = LastRequest.env[:body]
    expect(request.length).to eq 1
    expect { stubs.verify_stubbed_calls }.to_not raise_error
    expect(message_store.size).to be_zero
    message_store.stop_auto_sender
  end

end
