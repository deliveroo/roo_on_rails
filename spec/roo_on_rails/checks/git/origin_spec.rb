require 'spec_helper'
require 'support/check'
require 'roo_on_rails/checks/git/origin'

describe RooOnRails::Checks::Git::Origin, type: :check do
  context 'when the URL is valid' do
    before do
      shell.stub 'git config remote.origin.url',
        output: "git@github.com:deliveroo/roo_on_rails.git\n"
    end

    it_expects_check_to_pass
    it { expect { perform }.to change { context.git_org  }.to 'deliveroo' }
    it { expect { perform }.to change { context.git_repo }.to 'roo_on_rails' }
  end

  context 'when this is not a Git repository' do
    before do
      shell.stub 'git config remote.origin.url', success: false
    end

    it_expects_check_to_fail
  end
end
