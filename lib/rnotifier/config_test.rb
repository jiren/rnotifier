module Rnotifier
  class ConfigTest
    class TestException <StandardError;
    end

    def self.test
      begin
        raise TestException.new('Test exception')
      rescue Exception => e
        if Rnotifier::ExceptionData.new(e, {}).notify
          puts "Test Exception sent. Login to rnotifier.com and checkout."
        else
          puts "Problem sending exception to rnotifier.com. Check your API key or config."
        end
      end
    end

  end
end
