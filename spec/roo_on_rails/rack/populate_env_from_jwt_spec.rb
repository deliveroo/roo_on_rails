require 'spec_helper'
require 'rack'
require 'base64'
require 'roo_on_rails/rack/populate_env_from_jwt'

describe RooOnRails::Rack::PopulateEnvFromJWT, :webmock do
  subject(:call) { Rack::MockResponse.new(*app.call(env)) }
  let(:env) { { 'HTTP_AUTHORIZATION' => auth_header } }

  let(:rack_env_var) { 'production' }

  let(:app) { described_class.new(inner_app, logger: logger) }
  let(:inner_app) { -> env { [200, {}, []] } }
  let(:logger) { double('logger',
    info: -> msg {},
    warn: -> msg {},
    error: -> msg {}
  ) }

  around do |test|
    old_env = ENV['RACK_ENV']
    ENV['RACK_ENV'] = rack_env_var
    test.run
    ENV['RACK_ENV'] = old_env
  end

  TEST_PEM_PRV = File.read('spec/support/test_key.prv.pem').freeze
  TEST_JWK_PUB = File.read('spec/support/test_key.pub.jwk').freeze
  OTHER_JWK_PUB = File.read('spec/support/other_key.pub.jwk').freeze

  shared_examples 'roo.identity provided to inner app' do
    it 'should make the JWT available to the inner app' do
      expect(inner_app).to receive(:call) do |env|
        expect(env['roo.identity']).to eq(token)
        [200, {}, []]
      end

      subject
    end
  end

  shared_examples 'roo.identity missing from inner app' do
    it 'should make the JWT available to the inner app' do
      expect(inner_app).to receive(:call) do |env|
        expect(env['roo.identity']).to be_empty
        [200, {}, []]
      end

      subject
    end
  end

  context 'when no Authorization header is given' do
    let(:auth_header) { nil }

    it { should be_ok }
  end

  context 'when a Basic Authorization header is given' do
    let(:auth_header) { 'Basic somestuff' }

    it { should be_ok }
    include_examples 'roo.identity missing from inner app'
  end

  context 'when the Authorization header contains a JWT that has an invalid signature' do
    let(:auth_header) { "Bearer #{token.to_s}badsig" }
    let(:token) { JSON::JWT.new(hi: 'world').tap { |jwt| jwt.header[:alg] = 'ES256' } }

    context 'when in development mode' do
      let(:rack_env_var) { 'development' }

      it { should be_ok }
      include_examples 'roo.identity provided to inner app'
    end

    context 'when in production mode' do
      it { should be_unauthorized }
    end
  end

  context 'when the Authorization header contains a JWT that has a valid signature' do
    let(:auth_header) { "Bearer #{token.to_s}" }
    let(:jku) { 'https://deliveroo.co.uk/identity-keys/0.jwk' }
    let(:private_key) { OpenSSL::PKey::EC.new(TEST_PEM_PRV) }
    let(:claims) { { hi: 'world' } }
    let(:token) do
      JSON::JWT.new(claims).tap do |jwt|
        jwt.header[:jku] = jku
      end.sign(private_key, :ES256)
    end

    context 'when the signature matches the given public key' do
      before { stub_request(:get, jku).to_return(body: TEST_JWK_PUB) }

      it { should be_ok }
      include_examples 'roo.identity provided to inner app'

      context 'when the signature is right but the specified algorithm is incorrect' do
        # There is an attack vector where the nefarious individual uses the _public_ key to
        # sign the JWT, but specifies the HMAC signing mechanism. A poorly secured client will
        # see the HMAC declaration in the header, load the public key _as a string_ and check
        # the signature as if the public key was a shared password in an HMAC signature.
        # This test ensures that is not possible :)
        let(:token) do
          JSON::JWT.new(claims).tap do |jwt|
            jwt.header[:jku] = jku
          end.sign(TEST_PEM_PRV, :HS256)
        end

        it { should be_unauthorized }
      end
    end

    context 'when the jku specified is not whitelisted' do
      let(:jku) { 'https://hax0rs.com/sadface.jwk' }

      it { should be_unauthorized }
    end

    context 'when the jku specified does not exist' do
      let(:jku) { 'https://deliveroo.co.uk/identity-keys/not-here.jwk' }

      before { stub_request(:get, jku).to_return(status: 404) }

      it 'should raise an error for the rest of the stack to handle' do
        expect { subject }.to raise_error(Faraday::ResourceNotFound)
      end
    end

    context 'when the jku specified is not JSON' do
      let(:jku) { 'https://deliveroo.co.uk/identity-keys/trollface.jpg' }

      before { stub_request(:get, jku).to_return(body: 'wut') }

      it { should be_unauthorized }
    end

    context 'when the jku specified is not a JWK' do
      let(:jku) { 'https://deliveroo.co.uk/identity-keys/donovan.json' }

      before { stub_request(:get, jku).to_return(body: '{"rhythm": "rain"}') }

      it { should be_unauthorized }
    end

    context 'when the signature does not match the given public key' do
      before { stub_request(:get, jku).to_return(body: OTHER_JWK_PUB) }

      it { should be_unauthorized }
    end
  end
end
