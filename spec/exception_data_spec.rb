$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe Rnotifier::ExceptionData do

  before(:all) do
    rnotifier_init
    @exception = mock_exception
    @options = {:type => :rack}
    @url = 'http://example.com/?foo=bar&quux=bla'
    @vars = { 
      'HTTP_REFERER' => 'http://localhost:3000/',
      'HTTP_COOKIE' => '_test_app_session=yYUhYSVc1U291M2I5TWpsN0E9BjsARg%3D%3D--6d69651b1cfb6a98387eb2fd01005955b2ca5406; _gauges_unique=1;'
    }
    @env = Rack::MockRequest.env_for(@url, @vars)
  end

  it 'is initialize exception_data object for rack' do
    e_data = Rnotifier::ExceptionData.new(@exception, @env, @options)

    expect(e_data.exception).to eq @exception
    expect(e_data.options).to eq @options
    expect(e_data.request).to be_an_instance_of(Rack::Request)
  end

  it 'is build rack exception data' do
    e_data = Rnotifier::ExceptionData.new(@exception, @env, @options)
    data = e_data.rack_exception_data
    request_data = data[:request]

    expect(request_data[:url]).to eq @url
    expect(request_data[:http_method]).to eq 'GET'
    expect(request_data[:referer_url]).to eq @vars['HTTP_REFERER']

    headers = {'referer' => @vars['HTTP_REFERER'], 'cookie' => '_test_app_session=[FILTERED] _gauges_unique=1;'}
    expect(request_data[:headers]).to eq headers 
    expect(request_data[:params]).to eq({'foo' => 'bar', 'quux' => 'bla'})
    
    exception_data = data[:exception]
    expect(exception_data[:class_name]).to eq @exception.class.to_s
    expect(exception_data[:message]).to eq @exception.message 
  end

  it 'is filter parameters' do

    env = Rack::MockRequest.env_for(@url, {
     'action_dispatch.parameter_filter' =>[:password],
     'REQUEST_METHOD' => 'POST',
     :input => 'password=foo&useranme=bar'
    })

    e_data = Rnotifier::ExceptionData.new(@exception, env, @options)
    params = e_data.rack_exception_data[:request][:params]
    
    expect(params).to include({'password' => '[FILTERED]'})
    expect(params).to include({'useranme' => 'bar'})
  end


end
