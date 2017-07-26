require 'spec_helper'
require 'support/check'
require 'roo_on_rails/checks/documentation/playbook'

describe RooOnRails::Checks::Documentation::Playbook, type: :check do
  around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        File.write('PLAYBOOK.md', playbook_contents) if playbook_contents
        example.run
      end
    end
  end

  context 'when a playbook is present' do
    context 'when it has been filled in' do
      let(:playbook_contents) { 'Playbook content with no fixable bits' }

      it_expects_check_to_pass
    end

    context 'when it has not been filled in' do
      let(:playbook_contents) { 'Playbook content with FIXME in it' }

      it_expects_check_to_fail
    end
  end

  context 'when a playbook is not present' do
    let(:playbook_contents) { nil }

    it_expects_check_to_fail

    it do
      expect {
        silence_stream(STDOUT) { subject.fix }
      }.to change {
        File.exist?('PLAYBOOK.md')
      }.from(false).to(true)
    end
  end
end
