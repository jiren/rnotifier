class TestBenchmark


  def self.sum(n = 1000)
    n.times.inject(0) {|r, i| r = r + i; r}
  end

  def word_count(sentence)
    sentence.split.count
  end

  def raise_exception
    raise 'Test exception'
  end

  def sum_square(n = 10)
    sum = n.times.inject(0) {|r, i| r = r + i; r}
    sum*sum
  end
  benchmark_it :sum_square

  def self.sum_square_root(n = 10)
    sum = n.times.inject(0) {|r, i| r = r + i; r}
    Math.sqrt(sum)
  end

  benchmark_it :sum_square_root, :class_method => true

end
