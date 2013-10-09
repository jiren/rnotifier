module MockExceptions
  def mock_exception
    begin
      1 + '2'
    rescue Exception => e
      return e
    end
  end

  def mock_syntax_error
    e = SyntaxError.new("#{File.expand_path(__FILE__)}:#{__LINE__}: syntax error, unexpected ||, expecting '}'")
    e.set_backtrace([])
    return e
  end
end
