require 'spec_helper'
require 'roo_on_rails/config'

RSpec.describe RooOnRails::Config do
  FEATURES = [
    { name: "sidekiq", default: true },
    { name: "routemaster", default: false },
    { name: "routemaster_publishing", default: false }
  ]

  describe "::load" do
    subject { described_class.load }

    it "returns an arbitrarily queriable object" do
      expect(subject.foo).to be_nil
      expect(subject.bar).to be_nil
      subject.foo = 42
      expect(subject.foo).to eql 42
    end
  end

  FEATURES.each do |feature|
    describe "#{feature[:name]}_enabled?" do
      subject { described_class.send(:"#{feature[:name]}_enabled?") }
      let(:feature_env_var) { "#{feature[:name].upcase}_ENABLED" }

      before { @original = ENV[feature_env_var] }
      after  { ENV[feature_env_var] = @original }

      def set_env(value)
        ENV[feature_env_var] = value
      end

      specify "without any configured value it defaults to #{feature[:default].to_s}" do
        set_env nil
        expect(subject).to be feature[:default]
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
end
