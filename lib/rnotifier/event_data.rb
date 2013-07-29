module Rnotifier
  class EventData
    attr_reader :data

    EVENT = 0
    ALERT = 1

    def initialize(name, type, data = {}, tags = nil)
      @data = {
        :name => name, 
        :data => data,
        :app_env => EventData.app_env,
        :occurred_at => Time.now.to_i,
        :rnotifier_client => Config::CLIENT,
        :type => type,
      }
      @data[:context_data] = Thread.current[:rnotifier_context] if Thread.current[:rnotifier_context]
      @data[:tags] = tags if tags
    end

    def notify
      begin
        Notifier.send(data, Rnotifier::Config.event_path)
      rescue Exception => e
        Rlogger.error("[EVENT NOTIFY] #{e.message}")
        Rlogger.error("[EVENT NOTIFY] #{e.backtrace}")
      end
    end

    def self.app_env
      @app_env ||= {
        :env => Config.current_env,
        :pid => $$,
        :host => (Socket.gethostname rescue ''),
        :language => 'ruby'
      }
    end

  end
end
