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

      unless ENV['NEW_RELIC_LICENSE_KEY']
        abort 'Aborting: NEW_RELIC_LICENSE_KEY is required'
      end

      path = %w[new_relic.yml config/new_relic.yml].map { |p|
        Pathname.new(p) 
      }.find(&:exist?)
      if path
        abort "Aborting: new_relic.yml detected in '#{path.parent.realpath}', should not exist"
      end

      require 'newrelic_rpm'
      ::NewRelic::Agent.manual_start
    end
  end
end

