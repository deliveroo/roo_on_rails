require 'pathname'
require 'securerandom'
require 'thor'

module ROR
  module BuildTestApp
    ROOT = Pathname.new('../../..').expand_path(__FILE__)
    BUNDLE_CACHE = ROOT.join('vendor/bundle')
    TEST_DIR = ROOT.join('tmp/scaffold')
    RAILS_NEW_BASE_OPTIONS = '--skip-test --skip-git --skip-spring --skip-bundle'.freeze

    class Helper < Thor::Group
      include Thor::Actions

      def initialize(database: 'sqlite3', keep_scaffold: false)
        super()

        @database = database
        @keep_scaffold = keep_scaffold
      end

      def shell_run(command)
        say_status 'running', command.gsub(Dir.pwd, '$PWD')
        output = %x{#{command}}
        raise 'command failed' unless $?.success?
        output
      end

      def ensure_scaffold
        return self if scaffold_path.exist?
        scaffold_dir.rmtree if scaffold_dir.exist?
        TEST_DIR.mkpath

        shell_run "rails new #{scaffold_dir} #{rails_new_options}"

        if Rails::VERSION::MAJOR < 4
          append_to_file scaffold_dir.join('Gemfile'), %{
            gem 'sidekiq', '< 5'
          }
        end

        append_to_file scaffold_dir.join('Gemfile'), %{
          gem 'puma', '~> 3.0'
          gem 'roo_on_rails', path: '../../..'
        }

        create_file scaffold_dir.join('.env'),
          'NEW_RELIC_LICENSE_KEY=dead-0000-beef'

        # comment_lines scaffold_dir.join('config/database.yml').to_s,
        #   /^\s+username:/

        Bundler.with_clean_env do
          shell_run "cd #{scaffold_dir} && bundle install --path=#{BUNDLE_CACHE}"
        end

        shell_run "tar -C #{scaffold_dir} -cf #{scaffold_path} ."
        scaffold_dir.rmtree unless @keep_scaffold
        self
      rescue => e
        binding.pry
      end

      def unpack_scaffold_at(path)
        path.mkpath
        shell_run "tar -C #{path} -xf #{scaffold_path}"
        self
      end

      def clear_test_app_at(path)
        path.rmtree if path.exist?
        self
      end

      def self.clear_scaffolds
        new.say_status 'removing', 'scaffold app cache'
        TEST_DIR.rmtree if TEST_DIR.exist?
      end

      private

      def id
        @id ||= Digest::MD5.hexdigest(rails_new_options)
      end

      def rails_new_options
        "#{RAILS_NEW_BASE_OPTIONS} --database=#{@database}"
      end

      def scaffold_dir
        TEST_DIR.join("app-#{id}")
      end

      def scaffold_path
        TEST_DIR.join("app-#{id}.tar")
      end
    end


    def build_test_app
      let(:app_id) { '%s.%s' % [Time.now.strftime('%F.%H%M%S'), SecureRandom.hex(4)] }
      let(:app_path) { TEST_DIR.join(app_id) }
      let(:app_helper) { Helper.new(app_options) }
      let(:app_options) { {} }


      before do
        app_helper.ensure_scaffold.unpack_scaffold_at(app_path)
      end

      after do
        app_helper.clear_test_app_at(app_path)
      end
    end
  end
end


RSpec.configure do |config|
  config.extend ROR::BuildTestApp

  config.before(:suite) do
    ROR::BuildTestApp::Helper.clear_scaffolds
  end
end
