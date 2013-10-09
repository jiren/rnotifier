module Rnotifier
  class MessageStore

    #send after message count
    MESSAGE_COUNT = ENV['RN_DEBUG'] ? 2 : 50
    #Sleep time for auto sender thread to send messages
    AUTOSENDER_SLEEP_TIME = ENV['RN_DEBUG'] ? 2 : 90

    class << self
      attr_accessor :messages, :auto_sender_t

      def add(message)
        @messages << message
        self.send_messages if @messages.length >= MESSAGE_COUNT
        true
      end

      def size; self.messages.length; end
      def clear; self.messages.clear; end

      def send_messages
        count = MESSAGE_COUNT > self.messages.length ? self.messages.length : MESSAGE_COUNT

        if count > 0
          message_data = count.times.map{|i| e = self.messages.pop; e.data}
          Message.notify({:messages => message_data}, Config.messages_path)
        end
      end

      def start_auto_sender
        @auto_sender_t ||= Thread.new {
          loop do
            sleep(AUTOSENDER_SLEEP_TIME)
            send_messages unless @messages.empty?
          end
        }
      end

      def stop_auto_sender
        @auto_sender_t.kill if @auto_sender_t 
      end

    end

    #Default
    self.messages = Queue.new
    self.start_auto_sender unless ENV['RN_DEBUG']

  end
end
