require 'spec_helper'
require 'roo_on_rails/harness'
require 'roo_on_rails/checks/environment'

RSpec.describe RooOnRails::Harness do
  # Disable all of these.
  # While technically these tests are still useful, at the moment there is
  # no env-specific check, and these tests will fail.
  #
  xdescribe '#run' do
    let(:try_fix) { false }
    let(:context_value) { Hashie::Mash.new }
    let(:dry_run) { true }
    let(:checks_class) { RooOnRails::Checks::Environment }
    let(:instance) { described_class.new(try_fix: try_fix, context: context_value, dry_run: dry_run) }

    subject(:run) { instance.run }

    shared_examples 'runs checks' do |options|
      options.fetch(:for, []).each do |env_name|
        it "runs checks for #{env_name}" do
          run
          expect(context_value.deps.keys).to include(a_string_matching(/#{env_name}/))
        end
      end

      options.fetch(:not_for, []).each do |env_name|
        it "skips checks for #{env_name}" do
          run
          expect(context_value.deps.keys).not_to include(a_string_matching(/#{env_name}/))
        end
      end
    end

    context 'ROO_ON_RAILS_ENVIRONMENTS not specified' do
      include_examples 'runs checks', for: %i[production staging]
    end

    context 'ROO_ON_RAILS_ENVIRONMENTS=staging,production' do
      before { stub_config_var 'ROO_ON_RAILS_ENVIRONMENTS', 'staging,production' }

      include_examples 'runs checks', for: %i[production staging]
    end

    context 'ROO_ON_RAILS_ENVIRONMENTS=staging' do
      before { stub_config_var 'ROO_ON_RAILS_ENVIRONMENTS', 'staging' }
      include_examples 'runs checks', for: %i[staging], not_for: %i[production]
    end

    context 'ROO_ON_RAILS_ENVIRONMENTS=production' do
      before { stub_config_var 'ROO_ON_RAILS_ENVIRONMENTS', 'production' }
      include_examples 'runs checks', for: %i[production], not_for: %i[staging]
    end
  end
end
