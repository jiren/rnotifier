$:.unshift(File.dirname(__FILE__))
require 'spec_helper'

describe Rnotifier::EventData do

  before(:all) do
    rnotifier_init
    @name = 'product'
    @data = {:id => 1, :name => 'ProductX'}
  end

  it 'is initialize exception_data object' do
    e_data = Rnotifier::EventData.new(@name, @data)

    expect(e_data.data[:name]).to eq @name
    expect(e_data.data[:data]).to eq @data
    expect(e_data.data[:data_from]).to eq :event
  end

end
