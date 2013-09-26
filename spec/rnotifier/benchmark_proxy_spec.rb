require 'spec_helper'

describe Rnotifier::BenchmarkProxy do

  before(:all) do
    rnotifier_init
  end

  before(:each) do
    Rnotifier::MessageStore.clear
  end

  it 'delegate instance method execution through proxy' do
    sentence = "Object mixes in the Kernel module, making the built-in kernel functions globally accessible. Test string"
    wc = sentence.split.count
    result = TestBenchmark.new.benchmark({args: true}).word_count(sentence)

    expect(result).to eq wc
    expect(Rnotifier::MessageStore.size).to eq 1

    bm =  Rnotifier::MessageStore.messages.pop
    expect(bm.data[:name]).to eq("TestBenchmark#word_count")

    data = bm.data[:data]

    expect(data[:time]).not_to be_nil
    expect(data[:args]).to eq [sentence]
  end

  it 'delegate class method execution through proxy' do
    result = TestBenchmark.benchmark.sum(10)

    expect(result).to eq 45
    expect(Rnotifier::MessageStore.size).to eq 1
  end

  it 'also sends benchmark exception occure' do
    begin
      TestBenchmark.new.benchmark.raise_exception
    rescue Exception => e
      @excetion = e
    end

    expect(@excetion.backtrace.first).to match(/spec\/fixtures\/test_benchmark\.rb/)
    expect(Rnotifier::MessageStore.size).to eq 1
  end

  it 'did not capture method arguments if option args is not set' do
    result = TestBenchmark.benchmark.sum(10)
    
    expect(Rnotifier::MessageStore.size).to eq 1

    bm =  Rnotifier::MessageStore.messages.pop
    data = bm.data[:data]

    expect(data[:args]).to be_nil
  end

end
