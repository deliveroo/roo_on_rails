require 'spec_helper'
require 'roo_on_rails/config'

RSpec.describe RooOnRails::Config do

  describe "::load" do
    subject { described_class.load }

    it "returns an arbitrarily queriable object" do
      expect(subject.foo).to be_nil
      expect(subject.bar).to be_nil
      subject.foo = 42
      expect(subject.foo).to eql 42
    end
  end

  describe "sidekiq_enabled?" do
    subject { described_class.sidekiq_enabled? }

    before { @original = ENV['SIDEKIQ_ENABLED'] }
    after  { ENV['SIDEKIQ_ENABLED'] = @original }

    def set_env(value)
      ENV['SIDEKIQ_ENABLED'] = value
    end

    specify "without any configured value it defaults to true" do
      set_env nil
      expect(subject).to be true
    end

    specify "with a truthy setting it returns true" do
      set_env "true"
      expect(subject).to be true
      set_env "1"
      expect(subject).to be true
    end

    specify "with a non truthy setting it returns false" do
      set_env "false"
      expect(subject).to be false
      set_env "bangerang"
      expect(subject).to be false
    end
  end

  describe "google_auth_enabled?" do
    subject { described_class.google_auth_enabled? }

    before { @original = ENV['GOOGLE_AUTH_ENABLED'] }
    after  { ENV['GOOGLE_AUTH_ENABLED'] = @original }

    def set_env(value)
      ENV['GOOGLE_AUTH_ENABLED'] = value
    end

    specify "without any configured value it defaults to false" do
      set_env nil
      expect(subject).to be false
    end

    specify "with a truthy setting it returns true" do
      set_env "true"
      expect(subject).to be true
      set_env "1"
      expect(subject).to be true
    end

    specify "with a non truthy setting it returns false" do
      set_env "false"
      expect(subject).to be false
      set_env "bangerang"
      expect(subject).to be false
    end
  end
end
