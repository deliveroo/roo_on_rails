require 'roo_on_rails/logfmt'

RSpec.describe RooOnRails::Logfmt do
  describe '#dump' do
    subject { described_class.dump(hash) }

    context 'when passed nil' do
      let(:hash) { nil }

      it { should be_nil }
    end

    context 'when passed an empty hash' do
      let(:hash) { {} }

      it { should be_nil }
    end

    context 'when the hash contains only ident values' do
      let(:hash) { { s: 'stuff', y: :sym, i: 1234, f: 567.89, d: 47e78 } }

      it 'should output them in order without quoting' do
        should eq 's=stuff y=sym i=1234 f=567.89 d=4.7e+79'
      end
    end

    context 'when the hash contains a string with spaces' do
      let(:hash) { { s: 'even more stuff' } }

      it 'should quote the string' do
        should eq 's="even more stuff"'
      end
    end

    context 'when the hash contains a string with embedded quotes' do
      let(:hash) { { s: 'even "more" stuff' } }

      it 'should quote the string and escape the quotes' do
        should eq 's="even \"more\" stuff"'
      end
    end

    context 'when the hash contains a string with backslashes' do
      let(:hash) { { s: 'even \more\ stuff' } }

      it 'should quote the string and escape the backslashes' do
        should eq 's="even \\\\more\\\\ stuff"'
      end
    end

    context 'when the hash contains a string with returns' do
      let(:hash) { { s: "multiple\r\nlines" } }

      it 'should quote the string and escape the backslashes' do
        should eq 's="multiple\r\nlines"'
      end
    end

    context 'when the hash contains a nested hash' do
      let(:hash) { { h: { s: 'more stuff', i: 1234 } } }

      it 'should format the hash as escaped JSON' do
        should eq 'h="{\"s\":\"more stuff\",\"i\":1234}"'
      end
    end

    context 'when the hash contains a nested array' do
      let(:hash) { { a: ['more stuff', 1234] } }

      it 'should format the array as escaped JSON' do
        should eq 'a="[\"more stuff\",1234]"'
      end
    end
  end
end
