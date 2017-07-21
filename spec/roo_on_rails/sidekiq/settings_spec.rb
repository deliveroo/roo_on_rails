require 'roo_on_rails/sidekiq/settings'

RSpec.describe RooOnRails::Sidekiq::Settings do
  describe '.queues' do
    subject { described_class.queues }

    context 'default value' do
      it 'have default queues in the right sequence' do
        should eql %w[
          monitoring
          realtime
          within1minute
          within5minutes
          within30minutes
          within1hour
          within1day
          default
        ]
      end
    end

    context 'custom value' do
      before { stub_queues('realtime,queue-a:1day,queue-b:5seconds') }
      after  { reset_queues }

      it 'have custom queues in the right sequence' do
        should eql %w[queue-b realtime queue-a]
      end
    end
  end

  describe '.concurrency' do
    subject { described_class.concurrency }

    context 'default value' do
      it { should eql 25 }
    end

    context 'custom value' do
      before { stub_config_var('SIDEKIQ_THREADS', 2) }
      it { should eql 2 }
    end
  end
end
