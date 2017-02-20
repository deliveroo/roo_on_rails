require 'spec_helper'
require 'support/check'
require 'roo_on_rails/checks/heroku/login'

describe RooOnRails::Checks::Heroku::Login, type: :check do
  describe '#call' do
    context 'when already signed it' do
      before { shell.stub 'heroku whoami', output: "john.doe@example.com\n" }
      it_expects_check_to_pass
    end

    context 'when not signed it' do
      before { shell.stub 'heroku whoami', success: false }
      it_expects_check_to_fail
    end
  end
end
