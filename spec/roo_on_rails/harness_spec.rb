require 'spec_helper'
require 'roo_on_rails/harness'
require 'roo_on_rails/checks/environment'

RSpec.describe RooOnRails::Harness do
  describe '#run' do
    let(:try_fix) { false }
    let(:context_value) { {} }
    let(:checks_class) { RooOnRails::Checks::Environment }
    let(:staging_check) { instance_double(checks_class, run: true) }
    let(:production_check) { instance_double(checks_class, run: true) }
    let(:instance) {described_class.new(try_fix: try_fix, context: context_value) }

    subject(:run) { instance.run }

    before do
      allow(checks_class).to receive(:new) do |options|
        next unless options[:fix] == try_fix && options[:context] == context_value
        case options[:env]
        when 'staging'
          staging_check
        when 'production'
          production_check
        else
          nil
        end
      end
    end

    context 'ROO_ON_RAILS_ENVIRONMENTS not specified' do
      it 'runs staging and production checks' do
        expect(staging_check).to receive(:run).once
        expect(production_check).to receive(:run).once
        run
      end
    end

    context 'ROO_ON_RAILS_ENVIRONMENTS=staging,production' do
      before { stub_config_var 'ROO_ON_RAILS_ENVIRONMENTS', 'staging,production' }

      it 'runs staging and production checks' do
        expect(staging_check).to receive(:run).once.ordered
        expect(production_check).to receive(:run).once.ordered
        run
      end
    end

    context 'ROO_ON_RAILS_ENVIRONMENTS=staging' do
      before { stub_config_var 'ROO_ON_RAILS_ENVIRONMENTS', 'staging' }

      it 'runs staging check but not production check' do
        expect(staging_check).to receive(:run).once
        expect(production_check).to_not receive(:run)
        run
      end
    end

    context 'ROO_ON_RAILS_ENVIRONMENTS=production' do
      before { stub_config_var 'ROO_ON_RAILS_ENVIRONMENTS', 'production' }

      it 'runs production check but not staging check' do
        expect(production_check).to receive(:run).once
        expect(staging_check).to_not receive(:run)
        run
      end
    end
  end
end
