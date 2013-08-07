module Rnotifier
  class ConfigTest
    class TestException <StandardError;
    end

    def self.test
      begin
        raise TestException.new('Test exception')
      rescue Exception => e
        if status = Rnotifier.exception(e, {})
          puts "Test Exception sent. Login to www.rnotifier.com and checkout."
        else
          puts "Problem sending exception to www.rnotifier.com. Check your API key or config."
        end
        status
      end
    end

  end
end
