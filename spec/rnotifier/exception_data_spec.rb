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
    
    exception_data = e_data.exception_data
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

  it 'match the user agent is bot or not' do
    e_data = Rnotifier::ExceptionData.new(@exception, @env, @options)
    expect(e_data.is_bot?(nil)).to be_false

    user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/536.30.1 (KHTML, like Gecko) Version/6.0.5 Safari/536.30.1'
    expect(e_data.is_bot?(user_agent)).to be_false

    user_agent = "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
    env = Rack::MockRequest.env_for(@url, @vars.merge({'HTTP_USER_AGENT' => user_agent}))

    e_data = Rnotifier::ExceptionData.new(@exception, env, @options)
    expect(e_data.is_bot?(user_agent)).to be_true
  end

  it 'ignores error for unwanted bot request' do
    stubs = stub_faraday_request
    env = Rack::MockRequest.env_for(@url, {
     'REQUEST_METHOD' => 'POST',
     'HTTP_USER_AGENT' => 'Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)'
    })

    status = Rnotifier::ExceptionData.new(@exception, env, {:type => :rack}).notify

    expect(status).to be_false
    expect {stubs.verify_stubbed_calls }.to raise_error
  end

  it 'must not ingnore error other then unwanted bot agents' do
    stubs = stub_faraday_request
    env = Rack::MockRequest.env_for(@url, {
     'REQUEST_METHOD' => 'POST',
     'HTTP_USER_AGENT' => 'Mozilla/5.0 (compatible; CorrectBot'
    })

    status = Rnotifier::ExceptionData.new(@exception, env, {:type => :rack}).notify
    expect(status).to be_true
    expect {stubs.verify_stubbed_calls }.not_to raise_error
  end

  describe '#ignore_exceptions' do
    before(:each) do
      clear_config
      Rnotifier.load_config("#{Dir.pwd}/spec/fixtures/rnotifier_ignore_exception.yaml")
      @stubs = stub_faraday_request
    end

    it 'ignore errors unwanted errors' do
      class TestRouteNotFound < Exception; end
      exception = TestRouteNotFound.new('/test route not found')
      exception.set_backtrace([])

      status = Rnotifier::ExceptionData.new(exception, @env, {:type => :rack}).notify

      expect(status).to be_false
      expect {@stubs.verify_stubbed_calls }.to raise_error
    end

    it 'must not ignore_exceptions other then unwanted exceptions' do
      status = Rnotifier::ExceptionData.new(@exception, @env, {:type => :rack}).notify

      expect(status).to be_true
      expect {@stubs.verify_stubbed_calls }.not_to raise_error
    end
  end

  it 'sends exception manually' do
    stubs = stub_faraday_request
    params = {:manual_exception => true}

    status = Rnotifier.exception(@exception, params)

    expect(status).to be_true
    expect {stubs.verify_stubbed_calls }.to_not raise_error
  end

end
