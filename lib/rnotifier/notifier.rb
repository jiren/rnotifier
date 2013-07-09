module Rnotifier
  class Notifier
    class << self

      def connection
        @connection ||= Faraday.new(:url => Config.api_host) do |faraday|
          faraday.adapter Faraday.default_adapter  
        end
      end

      def send(data, url = nil)
        response = self.connection.post do |req|
          req.url(url || Config.notification_path)
          req.headers['Content-Type'] = 'application/json'
          req.headers['Api-Key'] = Config.api_key
          req.options[:timeout] =  Config[:http_open_timeout]
          req.options[:open_timeout] = Config[:http_read_timeout]
          req.body =  MultiJson.dump(data)
        end

        return true if response.status == 200
        Rlogger.error("[RNOTIFIER SERVER] Response Status:#{response.status}")
        false
      ensure
        Rnotifier.clear_context
      end
    end
  end
end
