require 'sinatra'
require 'sinatra/base'

module RnotifierTest

  class TestSinatraApp < Sinatra::Base
    set :environment, :production
    use Rnotifier::RackMiddleware, 'spec/fixtures/rnotifier_test.yaml'

    get '/' do
      [200, {}, 'OK']
    end

    get '/exception/1' do
      1 + '2'

      [200, {}, 'OK']
    end

    get '/event' do
      Rnotifier.event(:product, {:id => 1, :name => 'PS3' }, [:create])

      [200, {}, 'OK']
    end

  end

end
