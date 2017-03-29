module RooOnRails
  module Railties
    class RakeTasks < Rails::Railtie
      rake_tasks do
        $stderr.puts 'initializer roo_on_rails.rake_tasks'

        Dir[File.join(__dir__, '..', 'tasks', '*.rake')].each { |f| load f }
      end
    end
  end
end
