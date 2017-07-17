require 'spec_helper'
require 'support/check'
require 'roo_on_rails/checks/google_oauth/initializer'
require 'fileutils'

RSpec.describe RooOnRails::Checks::GoogleOauth::Initializer, type: :check do
  subject { described_class.new(fix: true) }
  let(:file_path) { "config/initializers/google_oauth.rb" }
  let(:file_dir) { "config/initializers/" }

  around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p(file_dir)
        File.write(file_path, "anything") if initializer_exists
        example.run
      end
    end
  end

  describe "when google auth is enabled" do
    before do
      allow(RooOnRails::Config).to receive(:google_auth_enabled?) { true }
    end

    context 'when the initializer is present' do
      let(:initializer_exists) { true }

      it_expects_check_to_pass
    end

    context 'when the initializer is not present' do
      let(:initializer_exists) { false }

      it_expects_check_to_fail

      it "creates the initializer file" do
        expect {
          silence_stream(STDOUT) { subject.run }
        }.to change {
          File.exist?(file_path)
        }.from(false).to(true)
      end
    end
  end

  describe "when google auth is NOT enabled" do
    let(:initializer_exists) { false }

    before do
      allow(RooOnRails::Config).to receive(:google_auth_enabled?) { false }
    end

    it_expects_check_to_pass

    it "does nothing" do
      expect {
        silence_stream(STDOUT) { subject.run }
      }.to_not change {
        File.exist?(file_path)
      }
    end
  end
end
