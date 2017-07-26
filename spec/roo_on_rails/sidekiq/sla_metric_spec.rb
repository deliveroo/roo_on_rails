require 'spec_helper'
require 'hashie/mash'
require 'sidekiq'
require 'roo_on_rails/sidekiq/sla_metric'

RSpec.describe RooOnRails::Sidekiq::SlaMetric do
  describe '#queue' do
    let(:sidekiq_queues) { [instance_double(Sidekiq::Queue, name: 'within1minute', latency: latency)] }

    before do
      allow(Sidekiq::Queue).to receive(:all).and_return(sidekiq_queues)
      allow(Sidekiq::ProcessSet).to receive(:new).and_return(process_set)
    end

    subject(:queue) { described_class.queue }

    context '1 process and queue latency is greater than threshold to increase' do
      let(:process_set) { [Hashie::Mash.new(quiet: 'false', queues: %w[within1minute])] }
      let(:latency) { 31.seconds.to_i }
      it { should eql 2 }
    end

    context '1 quiet process and queue latency is greater than threshold to increase' do
      let(:process_set) { [Hashie::Mash.new(quiet: 'true', queues: %w[within1minute])] }
      let(:latency) { 31.seconds.to_i }
      it { should eql 1 }
    end

    context '2 processes and queue latency is less than threshold to decrease' do
      let(:process_set) do
        [
          Hashie::Mash.new(quiet: 'false', queues: %w[within1minute]),
          Hashie::Mash.new(quiet: 'false', queues: %w[within1minute])
        ]
      end
      let(:latency) { 5.seconds.to_i }
      it { should eql 1 }
    end

    context '2 processes with only 1 configured queue process and queue latency equals permitted latency level for queue' do
      before { stub_queues 'within1minute' }
      after  { reset_queues }

      let(:process_set) do
        [
          Hashie::Mash.new(quiet: 'false', queues: %w[within1minute]),
          Hashie::Mash.new(quiet: 'false', queues: %w[new-queue])
        ]
      end

      let(:sidekiq_queues) do
        [
          instance_double(Sidekiq::Queue, name: 'within1minute', latency: latency),
          instance_double(Sidekiq::Queue, name: 'new-queue', latency: latency)
        ]
      end

      let(:process_count) { 2 }
      let(:latency) { 31.seconds.to_i }
      it { should eql 2 }
    end
  end
end
