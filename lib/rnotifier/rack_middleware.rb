module Rnotifier
  class RackMiddleware

    def initialize(app, config_file = nil)
      @app = app
      Rnotifier.load_config(config_file) if config_file 
    end

    def call(env)
      begin
        response = @app.call(env)
      rescue Exception => e
        Rnotifier::ExceptionData.new(e, env, {:type => :rack}).notify
        env['rnotifier.notify'] = true
        raise e
      end

      if e = (env['rack.exception'] || env['sinatra.error'])
        Rnotifier::ExceptionData.new(e, env, {:type => :rack}).notify
        env['rnotifier.notify'] = true
      end

      response
    end
  end
end
