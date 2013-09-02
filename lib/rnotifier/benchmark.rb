module Rnotifier
  class BenchmarkException < Exception; end

  class Benchmark
    BENCHMARK = 2

    def self.it(name, opts = {}, &block)
      output = nil
      exception = nil

      raise BenchmarkException.new("Code block require :#{name}") unless block_given?

      t1 = Time.now
      begin
        output = yield 
      rescue Exception => e
        exception = e
        exception.backtrace.shift(2) if exception.backtrace
      end

      self._collect(name, t1, Time.now, exception, opts)

      raise exception if exception
      return output
    end

    private
    def self._collect(name, t1, t2, exception, opts = {})
      params = { bm_time: (t2 - t1) }
      params[:data] = opts[:params] if opts[:params]
      params[:exception] = exception.message if exception

      notify = true
      notify = false if opts[:time_condition] && opts[:time_condition] >= params[:bm_time]
      Rnotifier::EventData.new(name, BENCHMARK, params).notify if notify
    end

  end
end
