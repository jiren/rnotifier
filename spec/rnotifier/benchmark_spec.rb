require 'spec_helper'

describe Rnotifier::Benchmark do

  before(:all) do
    rnotifier_init
  end

  before(:each) do
    @stub = stub_faraday_request({:path => Rnotifier::Config.event_path})
  end

  it 'benchmark code block' do
    result = Rnotifier::Benchmark.it(:test) { MockMethods.sum() }
    expect(result).to eq 10000
    expect { @stub.verify_stubbed_calls }.to_not raise_error
  end

  it 'benchmark code block by time trap condition' do
    result = Rnotifier::Benchmark.it(:test, {:time_condition => 0}) { MockMethods.sum() }
    expect(result).to eq 10000
    expect { @stub.verify_stubbed_calls }.to_not raise_error
  end

  it 'will not going to send benchmark data if time_condition value less then benchmark time' do
    result = Rnotifier::Benchmark.it(:test, {:time_condition => 2}) { MockMethods.sum() }

    expect(result).to eq 10000
    expect { @stub.verify_stubbed_calls }.to raise_error
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

end
