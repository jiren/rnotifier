module Rnotifier
  module BenchmarkFilters
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def rnotifier_benchmarking(*args)
        arg = args.first
        time_condition = if arg
                           arg.delete(:time_condition) || arg.delete('time_condition') 
                         else
                           nil
                         end

        self.send(:before_filter, arg) do
          @__bm_start_time = Time.now
          @__rn_b_token = Rnotifier::BenchmarkView.browser_token
        end

        self.send(:after_filter, arg) do
          if @__bm_start_time
            bm_name = "#{params[:controller]}##{params[:action]}"
            opts = {:time_condition => time_condition, :b_token => @__rn_b_token}

            Rnotifier::Benchmark.web_request(bm_name, Time.now - @__bm_start_time, request.url, opts) rescue ''
          end
        end
      end
    end

    module ViewHelperTag
      def rnotifier_tag
        Rnotifier::BenchmarkView.tag(@__rn_b_token).html_safe
      end
    end

    def self.load_bm_filters
      if defined?(ActionController::Base)
        ActionController::Base.send :include, Rnotifier::BenchmarkFilters

        if defined?(ActionView::Helpers)
          ActionView::Base.send :include, Rnotifier::BenchmarkFilters::ViewHelperTag
        end
      end
    end
  end
end
