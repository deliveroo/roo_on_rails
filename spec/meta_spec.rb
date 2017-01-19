require 'spec_helper'
require 'spec/support/build_test_app'
require 'spec/support/run_test_app'

describe ROR::BuildTestApp do
  build_test_app

  it 'builds a test app' do
    expect(app_path.join('Gemfile')).to exist
  end
end

describe ROR::RunTestApp do
  run_test_app

  it 'boots the app cleanly' do
    app.start.wait_start
  end

  it 'stops the app cleanly' do
    app.start.wait_start
    app.stop
    expect(app.status).to be_success
  end
end
