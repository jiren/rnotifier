module Rnotifier
  class Notifier
    class << self

      def connection
        @connection ||= Faraday.new(:url => Rnotifier::Config.api_host) do |faraday|
          faraday.adapter Faraday.default_adapter  
        end
      end

      def send(data)
        response = self.connection.post do |req|
          req.url Rnotifier::Config.notification_path
          req.headers['Content-Type'] = 'application/json'
          req.options[:timeout] =  Rnotifier::Config[:http_open_timeout]
          req.options[:open_timeout] = Rnotifier::Config[:http_read_timeout]
          req.body =  MultiJson.dump(data)
        end

        return true if response.status == 200
        Rlogger.error("[RNOTIFIER SERVER] Response Status:#{response.status}")
        false
      end
    end
  end
end
