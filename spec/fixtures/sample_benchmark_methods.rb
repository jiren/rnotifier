class MockMethods

  def self.sum(n = 10000)
    n.times.inject(0){|r, i| r = r + 1; r}
  end

end

