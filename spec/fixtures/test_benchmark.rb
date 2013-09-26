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

end
