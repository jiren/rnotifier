require 'spec_helper'

describe Rnotifier::ExceptionCode do

  before(:all) do
    @file =  Dir.pwd + '/spec/fixtures/code.text'
    @lines = File.readlines(@file)
    @total_lines = 18
  end

  let(:mock_exception_file) { Dir.pwd + "/spec/fixtures/mock_exception_methods.rb" }

  it 'collect error line' do 
    code = Rnotifier::ExceptionCode.find(@file, 5, 0)

    expect(code[0]).to eq (5 - 1)
    expect(code[1]).to eq @lines[4]
  end

  it 'collect error line with range context' do
    code = Rnotifier::ExceptionCode.find(@file, 5, 3)
    expect(code[0]).to eq (5 - 3 - 1)

    @lines[code[0]..(5 + 3 - 1)].each_with_index do |l, i|
      expect(code[i+1]).to eq l
    end

  end

  it 'collect error line from the file start' do
    code = Rnotifier::ExceptionCode.find(@file, 1, 3)
    expect(code[0]).to eq 0

    @lines[code[0]..3].each_with_index do |l, i|
      expect(code[i+1]).to eq l
    end
  end

  it 'collect error line from the end of file' do
    code = Rnotifier::ExceptionCode.find(@file, @lines.count, 3)
    expect(code[0]).to eq (@lines.count - 3 - 1)

    @lines[code[0]..-1].each_with_index do |l, i|
      expect(code[i+1]).to eq l
    end
  end

  it 'collect code lines for exception' do
    rnotifier_init
    code =  Rnotifier::ExceptionCode.get(mock_exception)
    lines = File.readlines(mock_exception_file)[0..6]

    expect(code).to eq([0].concat(lines))
  end

  it 'collect code lines for syntax error' do
    rnotifier_init
    e = mock_syntax_error
    code =  Rnotifier::ExceptionCode.get(e)
    lines = File.readlines(mock_exception_file)[7..-2]

    expect(code).to eq([7].concat(lines))
  end

  it 'return nil if backtrace is nil' do
    rnotifier_init

    e = Exception.new('No backtrace')
    code =  Rnotifier::ExceptionCode.get(e)

    expect(code).to be_nil
  end

  it 'return first line of backtrace if exception not a syntax error or not rails form app' do
    rnotifier_init
    Rnotifier::Config.app_env[:app_root] = '/noroot'

    e = Exception.new('Non app exception')
    e.set_backtrace(["#{mock_exception_file}:3:in `mock_exception'"])

    code =  Rnotifier::ExceptionCode.get(e)
    lines = File.readlines(mock_exception_file)[0..5]

    expect(code).to eq([0].concat(lines))
    rnotifier_init
  end


end
