module RooOnRails
  class Railtie < Rails::Railtie
    initializer 'roo_on_rails.default_env' do
      Rails.logger.with initializer: 'roo_on_rails.default_env' do |log|
        log.debug 'loading'
        require 'roo_on_rails/environment'
        RooOnRails::Environment.load
      end
    end
  end
end
