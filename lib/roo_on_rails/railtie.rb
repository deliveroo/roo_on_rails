$stderr.puts 'loading roo_on_rails railtie'

module RooOnRails
  class Railtie < Rails::Railtie
    initializer 'roo_on_rails.default_env' do
      $stderr.puts 'initializer roo_on_rails.default_env'
      Dotenv.load File.expand_path('../default.env', __FILE__)
    end

    # initializer 'roo_on_rails.print_env' do
    #   ENV.to_a.sort.each do |k,v|
    #     puts "#{k}: #{v}"
    #   end
    # end

    initializer 'roo_on_rails.new_relic' do
      $stderr.puts 'initializer roo_on_rails.new_relic'

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
