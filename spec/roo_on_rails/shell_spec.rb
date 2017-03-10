require 'spec_helper'
require 'roo_on_rails/shell'

describe RooOnRails::Shell do
  describe '#run' do
    let(:command) { 'echo 42 ; echo 43 >&2' }
    let(:result) { subject.run(command) }

    it 'returns status and standard output' do
      expect(result).to eq([true, "42\n"])
    end

    context 'when the command fails' do
      let(:command) { 'echo 42 ; exit 1' }

      it 'still returns output' do
        expect(result.last).to eq("42\n")
      end

      it 'reports failure' do
        expect(result.first).to be_falsy
      end
    end
  end

  describe 'run!' do
    let(:perform) { subject.run!(command) }

    context 'when command succeeds' do
      let(:command) { 'true' }
      it { expect { perform }.not_to raise_error }
    end

    context 'when command fails' do
      let(:command) { 'false' }
      it { expect { perform }.to raise_error(described_class::CommandFailed) }
    end
  end

  describe 'run?' do
    let(:result) { subject.run?(command) }

    context 'when command succeeds' do
      let(:command) { 'true' }
      it { expect(result).to be_truthy }
    end

    context 'when command fails' do
      let(:command) { 'false' }
      it { expect(result).to be_falsy }
    end
  end
end
