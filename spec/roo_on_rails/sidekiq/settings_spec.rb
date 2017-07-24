require 'roo_on_rails/sidekiq/settings'

RSpec.describe RooOnRails::Sidekiq::Settings do
  after  { reset_queues }

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

  describe '.permitted_latency_values' do
    subject { described_class.permitted_latency_values }

    context 'default value' do
      it { should eql(
        'monitoring' => 10.seconds.to_i,
        'realtime' => 10.seconds.to_i,
        'within1minute' => 1.minute.to_i,
        'within5minutes' => 5.minutes.to_i,
        'within30minutes' => 30.minutes.to_i,
        'within1hour' => 1.hour.to_i,
        'within1day' => 1.day.to_i,
        'default' => 1.day.to_i
      ) }
    end

    context 'custom value' do
      before { stub_queues('realtime,queue-a:1day,queue-b:5seconds,within32seconds') }

      it { should eql(
        'realtime' => 10.seconds.to_i,
        'queue-a' => 1.day.to_i,
        'queue-b' => 5.seconds.to_i,
        'within32seconds' => 32.seconds.to_i
      ) }
    end
  end
end
