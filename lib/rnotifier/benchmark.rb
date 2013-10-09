module Rnotifier
  class Benchmark

    RnotifierException = Class.new(Exception)

    BM_FIELDS = [:exception, :args]

    def self.it(bm_name, opts = {}, &block)
      output = nil
      exception = nil

      raise RnotifierException.new("Code block require :#{bm_name} for benchmarking.") unless block_given?

      t1 = Time.now
      begin
        output = yield 
      rescue Exception => e
        exception = e
        opts[:exception] = {:message => exception.message, :line => exception.backtrace.first}
      end

      self._collect(bm_name, Time.now - t1, opts)

      raise exception if exception
      return output
    end

    def self._collect(bm_name, time, opts)
      return if opts[:time_condition] && opts[:time_condition] >= time

      data = { :time => time}
      BM_FIELDS.each{|f| data[f] = opts[f] if opts[f]}

      bm_name = "#{opts[:class]}##{bm_name}" if opts[:class]

      Rnotifier::Message.new(bm_name, Rnotifier::Message::BENCHMARK, data).enq
    end

    def self.web_request(bm_name, time, request_url, opts)
      return if opts[:time_condition] && opts[:time_condition] >= time

      data = { :time => time, :request_url => request_url, :type => 'web', :b_token => opts[:b_token] }

      Rnotifier::Message.new(bm_name, Rnotifier::Message::BENCHMARK, data).enq
    end

  end
end
