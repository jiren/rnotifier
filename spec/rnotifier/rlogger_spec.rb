require 'spec_helper'

describe Rnotifier::Rlogger do

  it 'log exception with tag' do
    result = nil
    begin
      1 + '1'
    rescue Exception => e
      result = Rnotifier::Rlogger.exception(e, 'TEST')
    end

    expect(result).to be_false
  end
end
