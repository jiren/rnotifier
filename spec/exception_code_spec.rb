$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe Rnotifier::ExceptionCode do

  before(:all) do
    @file =  Dir.pwd + '/spec/code.text'
    @lines = File.readlines(@file)
    @total_lines = 18
  end

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
    
    lines = File.readlines(File.dirname(__FILE__) + "/mock_exception_helper.rb")[0..5]

    expect(code).to eq([0].concat(lines))
  end

  it 'collect code lines for systax error' do
    rnotifier_init
    e = mock_syntax_error
    code =  Rnotifier::ExceptionCode.get(e)

    lines = File.readlines(File.dirname(__FILE__) + "/mock_exception_helper.rb")[6..-1]

    expect(code).to eq([6].concat(lines))
  end

end
