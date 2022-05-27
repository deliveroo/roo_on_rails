require 'pathname'
require 'securerandom'
require 'thor'

module ROR
  module BuildTestApp
    ROOT = Pathname.new('../../..').expand_path(__FILE__)
    TEST_DIR = ROOT.join('tmp/scaffold')
    BUNDLE_CACHE = ROOT.join('vendor/bundle-scaffold').join(RUBY_VERSION)
    RAILS_NEW_BASE_OPTIONS = '--skip-test --skip-git --skip-spring --skip-bundle --skip-bootsnap'.freeze

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

        if $?.success?
          output
        else
          puts output
          raise "command: `#{command}` failed"
        end
      end

      def ensure_scaffold
        return self if scaffold_path.exist?
        scaffold_dir.rmtree if scaffold_dir.exist?
        TEST_DIR.mkpath

        require 'rails'

        shell_run "rails new #{scaffold_dir} #{rails_new_options} --skip-javascript"

        append_to_file scaffold_dir.join('Gemfile'), %{
          gem 'roo_on_rails', path: '#{ROOT}'
        }

        Bundler.with_clean_env do
          shell_run "cd #{scaffold_dir} && bundle install -j4 --retry=3 --path=#{BUNDLE_CACHE}"
        end

        shell_run "tar -C #{scaffold_dir} -cf #{scaffold_path} ."
        scaffold_dir.rmtree unless @keep_scaffold
        self
      end

      def write_dotenv_file(path, app_env_vars)
        create_file path.join('.env'), app_env_vars
      end

      def unpack_scaffold_at(path)
        shell_run "mkdir -p #{path}"
        shell_run "tar -C #{path} -xf #{scaffold_path}"
        self
      end

      def configure_database(path)
        config_path = path.join('./config/database.yml')

        if File.exist?(config_path)
          config = YAML.load_file(config_path)
          config['default']['variables'] = { 'statement_timeout' => -1 }

          remove_file(config_path)
          create_file(config_path, config.to_yaml)
        end
        
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
        options = [RAILS_NEW_BASE_OPTIONS]

        options << case @database
        when nil
          '--skip-active-record'
        else
          "--database=#{@database}"
        end

        options.join(' ')
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
      let(:app_env_vars) { "" }

      before do
        app_helper
          .ensure_scaffold
          .unpack_scaffold_at(app_path)
          .configure_database(app_path)
          .write_dotenv_file(app_path, app_env_vars)
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
