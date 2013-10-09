module Rnotifier
  class BenchmarkProxy < BasicObject

    instance_methods.each do |m|
      undef_method(m) if m.to_s !~ /(?:^__|^nil\?$|^send$|^object_id$)/
    end

    RBenchmark = ::Object.const_get('Rnotifier::Benchmark')
    Klass      = ::Object.const_get('Class')

    def initialize(target, opts = {})
      @target = target
      @opts = opts
    end

    def method_missing(method, *args, &block)
      @opts[:args] = args if @opts[:args]
      @opts[:class] = @target.is_a?(Klass) ? @target.name : @target.class.to_s
      RBenchmark.it(method, @opts){ @target.send(method, *args, &block) }
    end
  end
end
