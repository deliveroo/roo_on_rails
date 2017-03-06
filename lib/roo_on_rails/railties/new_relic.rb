module RooOnRails
  module Railties
    class NewRelic < Rails::Railtie
      initializer 'roo_on_rails.new_relic' do
        $stderr.puts 'initializer roo_on_rails.new_relic'

        license_key = ENV['NEW_RELIC_LICENSE_KEY']

        if %w[ test development ].exclude?(Rails.env.to_s) and license_key == 'override-me'
          abort 'Aborting: NEW_RELIC_LICENSE_KEY must be set in production environments'
        end

        if license_key.nil?
          abort 'Aborting: NEW_RELIC_LICENSE_KEY is required'
        end

        path = %w[newrelic.yml config/newrelic.yml].map { |p|
          Pathname.new(p)
        }.find(&:exist?)
        if path
          abort "Aborting: newrelic.yml detected in '#{path.parent.realpath}', should not exist"
        end

        require 'newrelic_rpm'
        ::NewRelic::Agent.manual_start unless Rails.env.test?
      end
    end
  end
end
