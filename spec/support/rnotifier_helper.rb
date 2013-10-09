module RnotifierHelper

  def rnotifier_init
    ENV['RACK_ENV'] = 'test'
    Rnotifier.load_config("#{Dir.pwd}/spec/fixtures/rnotifier.yaml")
  end

  def stub_faraday_request(opts = {})
    opts[:status] ||= 200
    opts[:message] ||= 'ok'
    opts[:path] ||= '/' + [ Rnotifier::Config::DEFAULT[:api_version], Rnotifier::Config::DEFAULT[:exception_path]].join('/')

    stubs = Faraday::Adapter::Test::Stubs.new
    conn  = Faraday.new do |c|
      c.adapter :test, stubs
    end

    stubs.post(opts[:path]) do |env|
      LastRequest.env = env 
      [opts[:status], {}, opts[:message]] 
    end

    Rnotifier::Notifier.instance_variable_set('@connection', conn)
    #Rnotifier::Notifier.connection = conn
    stubs
  end

  def clear_config
    [:api_key, :exception_path, :messages_path, :environments, :current_env,
      :app_env, :api_host, :ignore_exceptions, :capture_code].each do |m|
      Rnotifier::Config.send("#{m}=", nil)
      end
  end

end
