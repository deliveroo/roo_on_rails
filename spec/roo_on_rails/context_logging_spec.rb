require 'roo_on_rails/context_logging'

RSpec.describe RooOnRails::ContextLogging do
  let(:buffer) { StringIO.new }
  let(:base_logger) { defined?(ActiveSupport::Logger) ? ActiveSupport::Logger : ::Logger }
  let(:logger) { described_class.new(base_logger.new(buffer)) }
  let(:output) { buffer.string.chomp }

  describe '#with' do
    context 'when the log method is nested' do
      before { logger.with(i: 123, s1: 'stuff', s2: 'more stuff') { logger.info('hello world') } }

      it 'should output the message then the context as logfmt' do
        expect(output).to eq 'hello world i=123 s1=stuff s2="more stuff"'
      end
    end

    context 'when the log method is chained' do
      before { logger.with(i: 123, s1: 'stuff', s2: 'more stuff').info('hello world') }

      it 'should output the message then the context as logfmt' do
        expect(output).to eq 'hello world i=123 s1=stuff s2="more stuff"'
      end
    end

    context 'when the log method is nested within multiple context blocks' do
      before { logger.with(i: 123, s1: 'stuff') { logger.with(s2: 'more stuff') { logger.info('hello world') } } }

      it 'should output the message then the flattened context as logfmt' do
        expect(output).to eq 'hello world i=123 s1=stuff s2="more stuff"'
      end
    end

    context 'when the log method is chained within a context block' do
      before { logger.with(i: 123, s1: 'stuff') { logger.with(s2: 'more stuff').info('hello world') } }

      it 'should output the message then the flattened context as logfmt' do
        expect(output).to eq 'hello world i=123 s1=stuff s2="more stuff"'
      end
    end

    context 'when the log method is nested within multiple overlapping context blocks' do
      before { logger.with(i: 123, s: 'stuff') { logger.with(s: 'nonsense') { logger.info('hello world') } } }

      it 'should output the message then the flattened context as logfmt' do
        expect(output).to eq 'hello world i=123 s=nonsense'
      end
    end

    context 'when the log method is chained within an overlapping context block' do
      before { logger.with(i: 123, s: 'stuff') { logger.with(s: 'nonsense').info('hello world') } }

      it 'should output the message then the flattened context as logfmt' do
        expect(output).to eq 'hello world i=123 s=nonsense'
      end
    end
  end

  describe '#flush' do
    before do
      logger.with(i: 123, s: 'stuff') do
        logger.flush
        logger.info('hello world')
      end
    end

    it 'should clear the current context' do
      expect(output).to eq 'hello world'
    end
  end
end
