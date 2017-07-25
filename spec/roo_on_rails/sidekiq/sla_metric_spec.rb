require 'roo_on_rails/sidekiq/sla_metric'
require 'sidekiq'
RSpec.describe RooOnRails::Sidekiq::SlaMetric do
  let(:sidekiq_queues) do
    [
      double(name: 'within1minute', latency: latency)
    ]
  end

  before do
    allow(Sidekiq::Queue).to receive(:all) { sidekiq_queues }
    allow_any_instance_of(RooOnRails::Sidekiq::ProcessScaling).to receive(:current_processes){ process_count }
  end

  let(:perform){ described_class.queue }

  context "when there is 1 process and high latency" do
    let(:process_count) { 1 }
    let(:latency) { 60 }
    it "should requests 2 processes" do
      expect(perform).to eq 2
    end
  end

  context "when there is 2 process and low latency" do
    let(:process_count) { 2 }
    let(:latency) { 5 }
    it "should requests 1 process" do
      expect(perform).to eq 1
    end
  end
end
