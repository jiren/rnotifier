module Rnotifier
  class EventData
    attr_reader :data

    def initialize(name, data = {})
      @data = {
        :name => name, 
        :data => data,
        :app_env => EventData.app_env,
        :occurred_at => Time.now.utc.to_s,
        :data_from => :event,
        :rnotifier_client => Config::CLIENT,
      }
      @data[:context_data] = Thread.current[:rnotifier_context] if Thread.current[:rnotifier_context]
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
      @env ||= Rnotifier::Config.event_app_env 
    end

  end
end
