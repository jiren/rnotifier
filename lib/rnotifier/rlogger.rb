module Rnotifier
	class Rlogger
		TAG = '[RNOTIFIER]'

		class << self

      ['info', 'error', 'warn'].each do |level|
        class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{level}(msg)
			   	  logger.#{level}("#{TAG} \#{msg}")
          end
        METHOD
      end
      
      def init
        @logger = if defined?(Rails) && Rails.respond_to?(:logger) 
                    Rails.logger
                  else
                    require 'logger' unless defined?(Logger)
                    Logger.new($stdout)
                  end
      end

      def logger
        @logger
      end

      def exception(e, tag = '')
        self.error("[#{tag}] #{e.message}")
        self.error("[#{tag}] #{e.backtrace}")
        return false
      end

		end
	end
end
