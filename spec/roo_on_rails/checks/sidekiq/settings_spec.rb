require 'spec_helper'
require 'support/check'
require 'roo_on_rails/checks/sidekiq/settings'
require 'roo_on_rails/sidekiq/settings'
require 'erb'

describe RooOnRails::Checks::Sidekiq::Settings, type: :check do
  describe '#call' do
    context "if there are already settings" do
      before do
        File.write('config/sidekiq.yml', 'some string')
      end

      after do
        File.delete('config/sidekiq.yml')
      end
      it_expects_check_to_fail 'Custom Sidekiq settings found.'
    end
  end
end
