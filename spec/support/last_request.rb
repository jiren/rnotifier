class LastRequest

  class << self

    attr_reader :env

    def env=(e)
      if e
        @env = e.clone
        @env[:body] = JSON.parse(@env[:body])
        @env
      end
    end

    def clear
      @env = nil
    end


  end

end
