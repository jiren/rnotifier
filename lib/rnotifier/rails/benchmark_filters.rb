module Rnotifier

  module BenchmarkFilters
    module ClassMethods

      def rnotifier_benchmarking(*args)

        time_condition = nil
        if arg = args.first
          time_condition = arg.delete(:time_condition) || arg.delete('time_condition')
        end

        self.send(:before_filter, args) do
          @__bm_start_time = Time.now
          @__rn_b_token = Rnotifier::BenchmarkView.browser_token
        end

        self.send(:after_filter, args) do
          if @__bm_start_time
            bm_name = "#{params[:controller]}##{params[:action]}"
            opts = {:time_condition => time_condition, :b_token => @__rn_b_token}

            Rnotifier::Benchmark.web_request(bm_name, Time.now - @__bm_start_time, request.url, opts) rescue ''
          end
        end
      end

      def self.included(base)
        base.extend ClassMethods
      end
    end

    def self.load_filters
      if defined? ActionController::Base
        ActionController::Base.send :include, Rnotifier::BenchmarkFilters::ClassMethods
      end
    end

    self.load_filters

  end
end
