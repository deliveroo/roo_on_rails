require 'roo_on_rails/sidekiq/metrics_worker'

RSpec.describe RooOnRails::Sidekiq::MetricsWorker do
  let(:statsd) { RooOnRails.statsd }

  describe '#perform' do
    let(:perform) { described_class.new.perform }

    before do
      # allow(statsd).to receive(:batch).and_call_original
      allow(statsd).to receive(:gauge).with(any_args)
      allow(Sidekiq::Queue).to receive(:all).and_return(sidekiq_queues) if defined?(sidekiq_queues)
    end

    after { reset_queues }

    it 'should send all metrics in a batch' do
      expect(statsd).to receive(:batch).with(no_args).once
      perform
    end

    context 'with the default queue' do
      let(:sidekiq_queues) { [instance_double(Sidekiq::Queue, name: 'default', size: 37, latency: 293)] }

      it 'should send size, latency and normalised latency based on 1 day' do
        tags = ['queue:default']
        expect(statsd).to receive(:gauge).with('jobs.queue.size', 37, tags: tags)
        expect(statsd).to receive(:gauge).with('jobs.queue.latency', 293, tags: tags)
        expect(statsd).to receive(:gauge).with('jobs.queue.normalised_latency', 0.003, tags: tags)
        perform
      end
    end

    context 'with the realtime queue' do
      let(:latency) { 6.2 }
      let(:sidekiq_queues) { [instance_double(Sidekiq::Queue, name: 'realtime', size: 476, latency: latency)] }

      it 'should send size, latency and normalised latency based on 10 seconds' do
        tags = ['queue:realtime']
        expect(statsd).to receive(:gauge).with('jobs.queue.size', 476, tags: tags)
        expect(statsd).to receive(:gauge).with('jobs.queue.latency', 6.2, tags: tags)
        expect(statsd).to receive(:gauge).with('jobs.queue.normalised_latency', 0.62, tags: tags)
        perform
      end

      context 'when there is one process active' do
        let(:process_count) { 1 }

        before do
          allow(Sidekiq::ProcessSet).to receive(:new) do
            double(count: process_count)
          end
        end

        it 'should request 2 workers' do
          expect(statsd).to receive(:gauge).with('jobs.processes.requested', 2)
          perform
        end

        context 'when there is no load but two workers' do
          let(:process_count) { 2 }
          let(:latency) { 0 }

          it 'should request 1 workers' do
            expect(statsd).to receive(:gauge).with('jobs.processes.requested', 1)
            perform
          end
        end
      end
    end

    context 'with a within* queue' do
      let(:sidekiq_queues) { [instance_double(Sidekiq::Queue, name: 'within60minutes', size: 3948, latency: 134)] }

      before { stub_queues('within60minutes') }

      it 'should send size, latency and normalised latency based on the queue name' do
        tags = ['queue:within60minutes']
        expect(statsd).to receive(:gauge).with('jobs.queue.size', 3948, tags: tags)
        expect(statsd).to receive(:gauge).with('jobs.queue.latency', 134, tags: tags)
        expect(statsd).to receive(:gauge).with('jobs.queue.normalised_latency', 0.037, tags: tags)
        perform
      end
    end

    context 'with custom queues' do
      before do
        stub_queues('new-queue-a:1minute,new-queue-b:1hour,new-queue-c:3days')
        allow(statsd).to receive(:gauge).with(any_args)
      end

      context 'all Sidekiq queues are included in custom queue list' do
        let(:sidekiq_queues) do
          [
            instance_double(Sidekiq::Queue, name: 'new-queue-a', size: 100, latency: 300),
            instance_double(Sidekiq::Queue, name: 'new-queue-b', size: 50, latency: 2700),
            instance_double(Sidekiq::Queue, name: 'new-queue-c', size: 150, latency: 32400)
          ]
        end

        it 'reports metrics for all queues' do
          tags = ['queue:new-queue-a']
          expect(statsd).to receive(:gauge).with('jobs.queue.size', 100, tags: tags)
          expect(statsd).to receive(:gauge).with('jobs.queue.latency', 300, tags: tags)
          expect(statsd).to receive(:gauge).with('jobs.queue.normalised_latency', 5.00, tags: tags)

          tags = ['queue:new-queue-b']
          expect(statsd).to receive(:gauge).with('jobs.queue.size', 50, tags: tags)
          expect(statsd).to receive(:gauge).with('jobs.queue.latency', 2700, tags: tags)
          expect(statsd).to receive(:gauge).with('jobs.queue.normalised_latency', 0.75, tags: tags)

          tags = ['queue:new-queue-c']
          expect(statsd).to receive(:gauge).with('jobs.queue.size', 150, tags: tags)
          expect(statsd).to receive(:gauge).with('jobs.queue.latency', 32400, tags: tags)
          expect(statsd).to receive(:gauge).with('jobs.queue.normalised_latency', 0.125, tags: tags)

          perform
        end
      end

      context 'some Sidekiq queues are included in custom queue list' do
        let(:sidekiq_queues) do
          [
            instance_double(Sidekiq::Queue, name: 'new-queue-a', size: 100, latency: 300),
            instance_double(Sidekiq::Queue, name: 'new-queue-x', size: 50, latency: 2700),
            instance_double(Sidekiq::Queue, name: 'new-queue-c', size: 150, latency: 32400)
          ]
        end

        it 'reports metrics for queues included in custom queue list' do
          tags = ['queue:new-queue-a']
          expect(statsd).to receive(:gauge).with('jobs.queue.size', 100, tags: tags)
          expect(statsd).to receive(:gauge).with('jobs.queue.latency', 300, tags: tags)
          expect(statsd).to receive(:gauge).with('jobs.queue.normalised_latency', 5.00, tags: tags)

          tags = ['queue:new-queue-c']
          expect(statsd).to receive(:gauge).with('jobs.queue.size', 150, tags: tags)
          expect(statsd).to receive(:gauge).with('jobs.queue.latency', 32400, tags: tags)
          expect(statsd).to receive(:gauge).with('jobs.queue.normalised_latency', 0.125, tags: tags)

          perform
        end
      end

      context 'no Sidekiq queue is included in custom queue list' do
        let(:sidekiq_queues) do
          [
            instance_double(Sidekiq::Queue, name: 'new-queue-a', size: 100, latency: 300),
            instance_double(Sidekiq::Queue, name: 'new-queue-x', size: 50, latency: 2700),
            instance_double(Sidekiq::Queue, name: 'new-queue-c', size: 150, latency: 32400)
          ]
        end

        it 'does not report stats for any queues' do
          expect(statsd).to_not receive(:gauge).with('jobs.queue.size')
          expect(statsd).to_not receive(:gauge).with('jobs.queue.latency')
          expect(statsd).to_not receive(:gauge).with('jobs.queue.normalised_latency')
          perform
        end
      end
    end

    context 'with a queue whose permitted latency cannot be determined' do
      let(:sidekiq_queues) { [instance_double(Sidekiq::Queue, name: 'test', size: 3948, latency: 134)] }
      before { stub_queues('test') }
      specify { expect { perform }.to raise_error RuntimeError }
    end
  end
end
