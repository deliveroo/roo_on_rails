require 'roo_on_rails/sidekiq/settings'

RSpec.describe RooOnRails::Sidekiq::Settings do
  describe '.queues' do
    subject { described_class.queues }

    context 'default value' do
      it do
        should match_array(%w[
          monitoring
          realtime
          within1minute
          within5minutes
          within30minutes
          within1hour
          within1day
        ])
      end
    end

    context 'custom value' do
      before { stub_config_var('SIDEKIQ_QUEUES', 'queue-a,queue-b') }
      it { should match_array(%w[queue-a queue-b]) }
    end
  end

  describe '.concurrency' do
    subject { described_class.concurrency }

    context 'default value' do
      it { should eql 25 }
    end

    context 'custom value' do
      before { stub_config_var 'SIDEKIQ_THREADS', 2 }
      it { should eql 2 }
    end
  end
end
