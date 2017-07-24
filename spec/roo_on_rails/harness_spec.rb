require 'spec_helper'
require 'roo_on_rails/harness'
require 'roo_on_rails/checks/environment'

RSpec.describe RooOnRails::Harness do
  describe '#run' do
    let(:try_fix) { false }
    let(:context_value) { nil }
    let(:dry_run) { true }
    let(:checks_class) { RooOnRails::Checks::Environment }
    let(:instance) {described_class.new(try_fix: try_fix, context: context_value, dry_run: dry_run) }

    subject(:run) { instance.run }

    context 'ROO_ON_RAILS_ENVIRONMENTS not specified' do
      it 'returns instances of Checks::Environment' do
        expect(run).to all(be_a(checks_class))
        expect(run.map(&:env)).to eql %w[staging production]
      end
    end

    context 'ROO_ON_RAILS_ENVIRONMENTS=staging,production' do
      before { stub_config_var 'ROO_ON_RAILS_ENVIRONMENTS', 'staging,production' }

      it 'returns instances of Checks::Environment' do
        expect(run).to all(be_a(checks_class))
        expect(run.map(&:env)).to eql %w[staging production]
      end
    end

    context 'ROO_ON_RAILS_ENVIRONMENTS=staging' do
      before { stub_config_var 'ROO_ON_RAILS_ENVIRONMENTS', 'staging' }

      it 'returns instances of Checks::Environment' do
        expect(run).to all(be_a(checks_class))
        expect(run.map(&:env)).to eql %w[staging]
      end
    end

    context 'ROO_ON_RAILS_ENVIRONMENTS=production' do
      before { stub_config_var 'ROO_ON_RAILS_ENVIRONMENTS', 'production' }

      it 'returns instances of Checks::Environment' do
        expect(run).to all(be_a(checks_class))
        expect(run.map(&:env)).to eql %w[production]
      end
    end
  end
end
