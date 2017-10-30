require 'roo_on_rails/logger'

RSpec.describe RooOnRails::Logger do
  let(:buffer) { StringIO.new }
  let(:logger) { described_class.new(buffer) }
  let(:output) { buffer.string.chomp }

  describe '#with' do
    context 'when the log method is nested' do
      before { logger.with(i: 123, s1: 'stuff', s2: 'more stuff') { logger.info('hello-world') } }

      it 'should output the message then the context as logfmt' do
        expect(output).to eq 'at=INFO msg=hello-world i=123 s1=stuff s2="more stuff"'
      end
    end

    context 'when the log method is chained' do
      before { logger.with(i: 123, s1: 'stuff', s2: 'more stuff').info('hello-world') }

      it 'should output the message then the context as logfmt' do
        expect(output).to eq 'at=INFO msg=hello-world i=123 s1=stuff s2="more stuff"'
      end
    end

    context 'when the log method is nested within multiple context blocks' do
      before { logger.with(i: 123, s1: 'stuff') { logger.with(s2: 'more stuff') { logger.info('hello-world') } } }

      it 'should output the message then the flattened context as logfmt' do
        expect(output).to eq 'at=INFO msg=hello-world i=123 s1=stuff s2="more stuff"'
      end
    end

    context 'when the log method is chained within a context block' do
      before { logger.with(i: 123, s1: 'stuff') { logger.with(s2: 'more stuff').info('hello-world') } }

      it 'should output the message then the flattened context as logfmt' do
        expect(output).to eq 'at=INFO msg=hello-world i=123 s1=stuff s2="more stuff"'
      end
    end

    context 'when the log method is nested within multiple overlapping context blocks' do
      before { logger.with(i: 123, s: 'stuff') { logger.with(s: 'nonsense') { logger.info('hello-world') } } }

      it 'should output the message then the flattened context as logfmt' do
        expect(output).to eq 'at=INFO msg=hello-world i=123 s=nonsense'
      end
    end

    context 'when the log method is chained within an overlapping context block' do
      before { logger.with(i: 123, s: 'stuff') { logger.with(s: 'nonsense').info('hello-world') } }

      it 'should output the message then the flattened context as logfmt' do
        expect(output).to eq 'at=INFO msg=hello-world i=123 s=nonsense'
      end
    end
  end

  describe '#silence' do
    before { logger.silence { logger.info('hello-world') } }
    it 'should not output any log' do
      expect(output).to be_empty
    end
  end
end
