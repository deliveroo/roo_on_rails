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
        abort '*** NEW_RELIC_LICENSE_KEY is required'
      end

      if File.exist?('new_relic.yml') || File.exist?('config/new_relic.yml')
        abort '*** new_relic.yml detected, should not exist'
      end

      require 'newrelic_rpm'
      ::NewRelic::Agent.manual_start
    end
  end
end

