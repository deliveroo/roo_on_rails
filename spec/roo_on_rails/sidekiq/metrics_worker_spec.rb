require 'roo_on_rails/sidekiq/metrics_worker'

RSpec.describe RooOnRails::Sidekiq::MetricsWorker do
  let(:statsd) { RooOnRails.statsd }

  describe '#perform' do
    let(:perform) { described_class.new.perform }
    before do
      allow(statsd).to receive(:batch).and_call_original
      allow(statsd).to receive(:gauge)
    end

    it 'should send all metrics in a batch' do
      perform
      expect(statsd).to have_received(:batch).once.with(no_args)
    end

    context 'with the default queue' do
      before do
        allow(Sidekiq::Queue).to receive(:all) do
          [instance_double(Sidekiq::Queue, name: 'default', size: 37, latency: 293)]
        end
        perform
      end

      it 'should send size, latency and normalised latency based on 1 day' do
        expect(statsd).to have_received(:gauge).with(
          'jobs.queue.size', 37, tags: ['queue:default']
        ).ordered
        expect(statsd).to have_received(:gauge).with(
          'jobs.queue.latency', 293, tags: ['queue:default']
        ).ordered
        expect(statsd).to have_received(:gauge).with(
          'jobs.queue.normalised_latency', 0.003, tags: ['queue:default']
        ).ordered
      end
    end

    context 'with the realtime queue' do
      let(:latency) { 6.2 }
      before do
        allow(Sidekiq::Queue).to receive(:all) do
          [instance_double(Sidekiq::Queue, name: 'realtime', size: 476, latency: latency)]
        end
      end

      it 'should send size, latency and normalised latency based on 10 seconds' do
        perform
        expect(statsd).to have_received(:gauge).with(
          'jobs.queue.size', 476, tags: ['queue:realtime']
        ).ordered
        expect(statsd).to have_received(:gauge).with(
          'jobs.queue.latency', 6.2, tags: ['queue:realtime']
        ).ordered
        expect(statsd).to have_received(:gauge).with(
          'jobs.queue.normalised_latency', 0.62, tags: ['queue:realtime']
        ).ordered
      end

      context 'when there is one process active' do
        let(:process_count) { 1 }
        before do
          allow(Sidekiq::ProcessSet).to receive(:new) do
            double(count: process_count)
          end
        end

        it 'should request 2 workers' do
          perform
          expect(statsd).to have_received(:gauge).with('jobs.processes.requested', 2).ordered
        end

        context 'when there is no load but two workers' do
          let(:process_count) { 2 }
          let(:latency) { 0 }

          it 'should request 1 workers' do
            perform
            expect(statsd).to have_received(:gauge).with('jobs.processes.requested', 1).ordered
          end
        end
      end
    end

    context 'with a within* queue' do
      before do
        allow(Sidekiq::Queue).to receive(:all) do
          [instance_double(Sidekiq::Queue, name: 'within60minutes', size: 3948, latency: 134)]
        end
        perform
      end

      it 'should send size, latency and normalised latency based on the queue name' do
        expect(statsd).to have_received(:gauge).with(
          'jobs.queue.size', 3948, tags: ['queue:within60minutes']
        ).ordered
        expect(statsd).to have_received(:gauge).with(
          'jobs.queue.latency', 134, tags: ['queue:within60minutes']
        ).ordered
        expect(statsd).to have_received(:gauge).with(
          'jobs.queue.normalised_latency', 0.037, tags: ['queue:within60minutes']
        ).ordered
      end
    end


    context 'with an additional/custom queue' do
      before do
        stub_config_var(
          'SIDEKIQ_PERMITTED_LATENCY_VALUES',
          'a:1:hour,new-que:1:minute,b:3:days'
        )

        allow(Sidekiq::Queue).to receive(:all) do
          [instance_double(Sidekiq::Queue, name: 'new-que', size: 100, latency: 300)]
        end

        allow(statsd).to receive(:gauge).with(any_args)
        perform
      end

      it 'should send size, latency and normalised latency based on the queue name' do
        expect(statsd)
          .to have_received(:gauge)
          .with('jobs.queue.size', 100, tags: ['queue:new-que'])
          .once

        expect(statsd)
          .to have_received(:gauge)
          .with('jobs.queue.latency', 300, tags: ['queue:new-que'])
          .once

        expect(statsd)
          .to have_received(:gauge)
          .with('jobs.queue.normalised_latency', 5.0, tags: ['queue:new-que'])
          .once
      end
    end

    context 'with a queue whose permitted latency cannot be determined' do
      before do
        allow(Sidekiq::Queue).to receive(:all) do
          [instance_double(Sidekiq::Queue, name: 'test', size: 3948, latency: 134)]
        end
      end

      it { expect { perform }.to raise_error RuntimeError }
    end
  end
end
