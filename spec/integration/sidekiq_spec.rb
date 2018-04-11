require 'spec_helper'
require 'spec/support/run_test_app'

describe "sidekiq loader" do
  run_sidekiq
  before { app.wait_start }

  it 'starts and stops the app cleanly' do
    app.start.wait_start
    app.stop
    expect(app.status).to be_success
  end

end
