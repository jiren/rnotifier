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
        #exception.backtrace.shift(opts[:_from] == :proxy ? 4 : 2) if exception.backtrace
        opts[:_exception] = exception.message
      end

      self._collect(name, Time.now - t1, opts)

      raise exception if exception
      return output
    end

    def self._collect(name, bm_time, opts)
      return if opts[:time_condition] && opts[:time_condition] >= bm_time

      params = { bm_time: bm_time}
      params[:data] = opts[:params] if opts[:params]
      params[:exception] = opts[:_exception] if opts[:_exception]
      params[:args] = opts[:args] if opts[:args]

      Rnotifier::EventData.new(name, BENCHMARK, params).notify
    end

  end
end
