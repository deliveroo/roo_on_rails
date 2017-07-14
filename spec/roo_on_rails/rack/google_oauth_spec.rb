require 'spec_helper'
require 'roo_on_rails/rack/google_oauth'
require 'rack/test'

RSpec.describe RooOnRails::Rack::GoogleOauth do
  include Rack::Test::Methods

  let(:inner_app) do
    -> (env) { [418, {}, ["I'm a Teapot."]] }
  end

  let(:auth_strategy) do
    -> (env) { [302, { "Location" => "/"}, ["you've been authenticated"]] }
  end

  # rack/test will need the `#app()` method avalable
  let(:app) { described_class.new(inner_app, &auth_strategy) }

  describe "for oauth requests" do
    def perform
      get "/auth/google_oauth2/callback?state=foo&code=bar"
    end

    it "runs the strategy block" do
      expect(auth_strategy).to receive(:call).with(an_instance_of(Hash)).and_call_original
      perform
    end

    it "returns the right response" do
      perform
      expect(last_response.status).to eql 302
    end
  end

  describe "for other requests" do
    def perform
      get "/"
    end

    it "does NOT run the strategy block" do
      expect(auth_strategy).to_not receive(:call)
      perform
    end

    it "returns the right response" do
      perform
      expect(last_response.status).to eql 418
    end
  end
end
