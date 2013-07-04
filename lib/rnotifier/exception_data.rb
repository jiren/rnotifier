module Rnotifier
  class ExceptionData
    attr_reader :env, :request, :exception, :options

    def initialize(exception, env, options = {})
      @exception = exception
      @options   = options  
      if options[:type] == :rack
        @request = Rack::Request.new(env)
      else
        @env = env
      end
    end

    def notify
      return unless Config.valid?
      return if Config.ignore_exceptions && Config.ignore_exceptions.include?(exception.class.to_s)

      begin
        data = options[:type] == :rack ? self.rack_exception_data : {:extra => self.env }

        data[:app_env] = Rnotifier::Config.app_env
        data[:occurred_at] = Time.now.utc.to_s
        data[:exception] = self.exception_data
        data[:context_data] = Thread.current[:rnotifier_context] if Thread.current[:rnotifier_context]
        data[:data_from] = options[:type]
        data[:rnotifier_client] = Config::CLIENT 

        return Notifier.send(data)
      rescue Exception => e
        Rlogger.error("[NOTIFY] #{e.message}")
        Rlogger.error("[NOTIFY] #{e.backtrace}")
      end
      false
    end

    def rack_exception_data
      data = {}
      data[:request] = {
        :url               => request.url,
        :referer_url       => request.referer,
        :ip                => request.ip,
        :http_method       => "#{request.request_method}#{' # XHR' if request.xhr?}",
        :params            => filtered_params,
        :headers           => self.headers,
        :session           => request.session
      }

      data
    end

    def exception_data
      e_data = {
        :class_name => exception.class.to_s,
        :message    => exception.message,
        :backtrace  => exception.backtrace,
        :fingerprint => (self.fingerprint rescue nil)
      }
      e_data[:code] = ExceptionCode.get(e_data[:backtrace]) if Config.capture_code
      e_data
    end

    def fingerprint
      #data[:fingerprint] = Digest::MD5.hexdigest("#{exception.message.gsub(/#<\w*:\w*>/, '')}#{data[:fingerprint]}")

      if exception.backtrace && !exception.backtrace.empty?
        Digest::MD5.hexdigest(exception.backtrace.join)
      end
    end

    def filtered_params
      if rp = request.env['action_dispatch.parameter_filter'] 
        ParameterFilter.filter(request.env['action_dispatch.request.parameters'] || request.params, rp)
      else 
        ParameterFilter.default_filter(request.params)
      end
    end

    HEADER_REGX = /^HTTP_/

    def headers
      headers = {}
      request.env.each do |k, v| 
        headers[k.sub(HEADER_REGX, '').downcase] = v if k =~ HEADER_REGX 
      end
      headers['cookie'] = headers['cookie'].sub(/_session=\S+/, '_session=[FILTERED]') if headers['cookie']
      headers
    end


  end
end
