module GlobalHelpers
  def stub_config_var(key, value)
    allow(ENV).to receive(:key?).with(any_args).and_call_original
    allow(ENV).to receive(:[]).with(any_args).and_call_original
    allow(ENV).to receive(:fetch).with(any_args).and_call_original

    allow(ENV).to receive(:key?).with(key).and_return(true)
    allow(ENV).to receive(:[]).with(key).and_return(value)
    allow(ENV).to receive(:fetch).with(key, any_args).and_return(value)
  end
end
