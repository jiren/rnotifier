module Rnotifier
  module BenchmarkMethods
    def benchmark(opts = {})
      Rnotifier::BenchmarkProxy.new(self, opts)
    end
  end

  module BenchmarkClassMethods
    def benchmark_it(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      args.each do |method_name|
        aliased_method, punctuation = method_name.to_s.sub(/([?!=])$/, ''), $1
        with_method, without_method = "#{aliased_method}_with_bm#{punctuation}", "#{aliased_method}_without_bm#{punctuation}"
        __bm_method__(method_name, with_method, without_method , opts)
      end
    end

    def __bm_method__(method_name, with_method, without_method, opts)
      method_definer = opts[:class_method] ? method(:define_singleton_method) : method(:define_method)
      method_definer.call(with_method) do |*args|
        Rnotifier::Benchmark.it(method_name, opts){ self.send(without_method, *args) }
      end

      if opts[:class_method]
        self.singleton_class.send(:alias_method, without_method, method_name)
        self.singleton_class.send(:alias_method, method_name, with_method)
      else
        alias_method without_method,  method_name
        alias_method method_name, with_method
      end
    end
  end

end
