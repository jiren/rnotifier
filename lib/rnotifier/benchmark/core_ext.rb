module BenchmarkMethods
  def benchmark(opts = {})
    Rnotifier::BenchmarkProxy.new(self, opts)
  end
end

Object.send(:include, BenchmarkMethods)
