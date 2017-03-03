require 'spec_helper'
require 'support/check'
require 'roo_on_rails/checks/github/token'

describe RooOnRails::Checks::GitHub::Token, type: :check do
  describe '#call' do
    let(:token_file) { File.expand_path('~/.roo_on_rails/github-token') }

    context 'when an access token is stored locally', :memfs do
      before do
        MemFs.touch(token_file) && File.write(token_file, 'faketoken')
      end

      context 'and the token is valid' do
        before do
          allow_any_instance_of(Octokit::Client).to receive(:user)
        end

        it_expects_check_to_pass
        it 'should set the github.api_client context property' do
          expect { perform }.to change { context.github&.api_client }
            .from(nil)
            .to(kind_of(Octokit::Client))
        end
      end

      context 'but the token is invalid' do
        before do
          allow_any_instance_of(Octokit::Client).to receive(:user).and_raise(Octokit::Unauthorized)
        end

        it_expects_check_to_fail
      end
    end
  end
end
