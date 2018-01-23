module RooOnRails
  module Railties
    class NewRelic < Rails::Railtie
      initializer 'roo_on_rails.new_relic' do
        Rails.logger.with initializer: 'roo_on_rails.new_relic' do |log|
          log.debug 'loading'
          license_key = ENV['NEW_RELIC_LICENSE_KEY']

          if %w(test development).exclude?(Rails.env.to_s) && (license_key == 'override-me')
            abort 'Aborting: NEW_RELIC_LICENSE_KEY must be set in production environments'
          end

          abort 'Aborting: NEW_RELIC_LICENSE_KEY is required' if license_key.nil?

          path = %w(newrelic.yml config/newrelic.yml).map do |p|
            Pathname.new(p)
          end.find(&:exist?)
          if path
            abort "Aborting: newrelic.yml detected in '#{path.parent.realpath}', should not exist"
          end

          sync_startup = (ENV.fetch('NEW_RELIC_SYNC_STARTUP', 'YES') =~ /\A(YES|TRUE|ON|1)\Z/i)

          require 'newrelic_rpm'
          unless Rails.env.test?
            ::NewRelic::Control.instance.init_plugin(sync_startup: sync_startup)
          end
        end
      end
    end
  end
end
