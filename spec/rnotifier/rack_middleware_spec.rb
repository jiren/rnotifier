require 'spec_helper'

describe Rnotifier::RackMiddleware do

  before(:all) do
    @type_error = "TypeError - String can't be coerced into Fixnum"
  end

  before(:each) do
    @stubs = stub_faraday_request
  end

  it 'sends get request and catche exception' do
    get "/exception/1" 

    expect(last_response.errors.split(/:\n/).first).to eq @type_error 
    expect(last_response.status).to eq 500
    expect { @stubs.verify_stubbed_calls }.to_not raise_error
  end

end
