module RooOnRails
  class Railtie < Rails::Railtie
    initializer 'roo_on_rails.default_env' do
      Rails.logger.debug "[roo_on_rails.default_env] loading"
      require 'roo_on_rails/environment'
      RooOnRails::Environment.load
    end
  end
end
