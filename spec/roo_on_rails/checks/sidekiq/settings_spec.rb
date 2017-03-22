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
      it_expects_check_to_fail 'Custom sidekiq settings found'
    end

    context "if there are no settings" do
      it_expects_check_to_fail 'No sidekiq settings found'
    end
  end

  describe "#fix" do
    let(:perform) { silence_stream(STDOUT) { subject.fix } }
    it_expects_check_to_pass
    let(:settings) do
      File.read('config/sidekiq.yml')
    end
    let(:rendered_settings) do
       ERB.new(settings).result()
    end
    it "adds a sidekiq settings file that renders our settings" do
      expect(rendered_settings).to eq RooOnRails::Sidekiq::Settings.settings_template
    end
  end
end
