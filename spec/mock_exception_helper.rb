def mock_exception
  begin
    1 + '2'
  rescue Exception => e
    return e
  end
end

def mock_syntax_error
  e = SyntaxError.new("#{File.dirname(__FILE__)}/mock_exception_helper.rb:#{__LINE__}: syntax error, unexpected ||, expecting '}'")
  e.set_backtrace([])
  return e
end
