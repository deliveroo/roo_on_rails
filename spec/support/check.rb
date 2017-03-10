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
    def it_expects_check_to_fail
      it { expect { perform }.to raise_error(RooOnRails::Checks::Failure) }
      it do
        expect do
          begin
                   perform
                 rescue
                   nil
                 end
        end.not_to change { context }
      end
    end

    def it_expects_check_to_pass
      it { expect { perform }.not_to raise_error }
    end

    # def resolved(sig)
    #   before do
    #     context.deps ||= {}
    #     context.deps[sig.to_s] = true
    #   end
    # end
  end
end

RSpec.configure do |conf|
  conf.include SpecSupportCheck, type: :check
end
