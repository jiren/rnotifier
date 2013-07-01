module Rnotifier
  class Railtie < Rails::Railtie

    initializer 'rnotifier.initialize' do |app|

      file = File.join(Rails.root, 'config', 'rnotifier.yaml')
      File.exist?(file) ? Rnotifier.load_config(file) : Rnotifier::Config.init

      if Rnotifier::Config.valid?
        if defined?(ActionDispatch::DebugExceptions)
          app.middleware.insert_after ActionDispatch::DebugExceptions, Rnotifier::RackMiddleware
        elsif defined?(ActionDispatch::ShowExceptions)
          app.middleware.insert_after ActionDispatch::ShowExceptions, Rnotifier::RackMiddleware
        else
          app.middleware.use Rnotifier::RackMiddleware
        end
      end
    end

  end
end
