module RooOnRails
  module Railties
    class NewRelic < Rails::Railtie
      initializer 'roo_on_rails.new_relic' do
        Rails.logger.debug 'initializer roo_on_rails.new_relic'

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

        require 'newrelic_rpm'
        ::NewRelic::Agent.manual_start unless Rails.env.test?
      end
    end
  end
end
