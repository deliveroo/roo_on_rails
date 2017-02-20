require 'spec_helper'
require 'hashie'
require 'support/fake_shell'
require 'support/silencer'
require 'roo_on_rails/checks/git/origin'

describe RooOnRails::Checks::Git::Origin do
  let(:shell) { FakeShell.new }
  let(:context) { Hashie::Mash.new }

  subject { described_class.new(shell: shell, context: context) }

  let(:perform) { silence_stream(STDOUT) { subject.run } }

  context 'when the URL is valid' do
    before do
      shell.stub 'git config remote.origin.url',
        output: "git@github.com:deliveroo/roo_on_rails.git\n"
    end

    it { expect { perform }.to change { context.git_org  }.to 'deliveroo' }
    it { expect { perform }.to change { context.git_repo }.to 'roo_on_rails' }
  end

  context 'when this is not a Git repository' do
    before do
      shell.stub 'git config remote.origin.url', success: false
    end

    it { expect { perform }.to raise_error(RooOnRails::Checks::Failure) }
    it { expect { perform rescue nil }.not_to change { context.git_org  } }
    it { expect { perform rescue nil }.not_to change { context.git_repo } }
  end
end
