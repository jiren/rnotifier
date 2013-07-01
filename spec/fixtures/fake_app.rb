require 'sinatra'
require 'sinatra/base'

module RnotifierTest

  class FakeApp < Sinatra::Base
    use Rnotifier::RackMiddleware, 'spec/fixtures/rnotifier_test.yaml'

    get '/' do
      [200, {}, 'OK']
    end

    get '/exception/1' do
      1 + '2'

      [200, {}, 'OK']
    end

  end

end
