module Rnotifier
  class Message
    attr_reader :data

    EVENT     = 0
    ALERT     = 1
    BENCHMARK = 2

    def initialize(name, type, data = {}, tags = nil)
      @data = {
        :name => name, 
        :data => data,
        :occurred_at => Time.now.to_i,
        :type => type,
        :env => Message.app_env
      }

      @data[:tags] = tags if tags
    end

    def notify
      self.class.notify({:messages => self.data}, Config.messages_path)
    end

    def enq
      Rnotifier::MessageStore.add(self) if Config.valid?
    end

    class << self
      def notify(data, path)
        return false unless Config.valid?

        begin
          return Notifier.send_data(data, path)
        rescue Exception => e
          Rlogger.exception(e, 'EVENT NOTIFY')
        end
      end

      def bulk_notify(messages)
        self.notify(messages, Config.messages_path)
      end

      def app_env
        @app_env ||= Config.basic_env
      end
    end

  end
end
