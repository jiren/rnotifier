require 'spec_helper'

describe Rnotifier::Benchmark do

  before(:all) do
    rnotifier_init
  end

  before(:each) do
    Rnotifier::MessageStore.clear
  end

  it 'benchmark code block' do
    result = Rnotifier::Benchmark.it(:test) { MockMethods.sum() }
    expect(result).to eq 10000

    expect(Rnotifier::MessageStore.size).to eq 1
  end

  it 'benchmark code block by time trap condition' do
    result = Rnotifier::Benchmark.it(:test, {:time_condition => 0}) { MockMethods.sum() }
    expect(result).to eq 10000
    expect(Rnotifier::MessageStore.size).to eq 1
  end

  it 'will not going to send benchmark data if time_condition value less then benchmark time' do
    result = Rnotifier::Benchmark.it(:test, {:time_condition => 2}) { MockMethods.sum() }

    expect(result).to eq 10000
    expect(Rnotifier::MessageStore.size).to eq 0
  end

  it 'raise excetion from the benchmark code bock' do
    expect{ 
      Rnotifier::Benchmark.it(:test, {:time_condition => 2}) { raise 'Test ExceptionData' }
    }.to raise_error
  end
   
  it 'remove backtrace of the benchmark lib code lines if excetion raise from benchmark code block' do
    begin
      Rnotifier::Benchmark.it(:test, {:time_condition => 2}) { raise 'Test ExceptionData' }
    rescue Exception => e
      @excetion = e
    end

    expect(@excetion.backtrace.first).to match(/spec\/rnotifier\/benchmark_spec\.rb/)
  end

  context('#benchmark_it') do

    it 'benchmark for instance method' do
      #TestBenchmark.benchmark_it :sum_square
      result = TestBenchmark.new.sum_square(10)
      
      expect(result).to eq(45*45)
      expect(Rnotifier::MessageStore.size).to eq 1
    end

    it 'benchmark for class method' do
      #TestBenchmark.benchmark_it :sum_square_root
      result = TestBenchmark.sum_square_root(10)
      
      expect(result).to eq(Math.sqrt(45))
      expect(Rnotifier::MessageStore.size).to eq 1
    end

  end

end
