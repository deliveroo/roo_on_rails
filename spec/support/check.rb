require 'hashie'
require 'support/silencer'
require 'spec/support/fake_shell'

module SpecSupportCheck
  def self.included(by)
    by.extend(Dsl)

    by.let(:shell) { FakeShell.new }
    by.let(:context) { Hashie::Mash.new }
    by.subject { described_class.new(shell: shell, context: context) }

    by.let(:perform) { silence_stream(STDOUT) { subject.call } }
  end

  module Dsl
    def it_expects_check_to_fail(message = nil)
      it { expect { perform rescue nil }.not_to change { context } }
      if message
        it { expect { perform }.to raise_error(RooOnRails::Checks::Failure, /#{message}/) }
      else
        it { expect { perform }.to raise_error(RooOnRails::Checks::Failure) }
      end
    end

    def it_expects_check_to_pass
      it { expect(subject.intro).to be_a_kind_of(String) }
      it { expect { perform }.not_to raise_error }
    end
  end
end

RSpec.configure do |conf|
  conf.include SpecSupportCheck, type: :check
end
