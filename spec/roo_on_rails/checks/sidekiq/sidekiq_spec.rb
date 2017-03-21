require 'spec_helper'
require 'support/check'
require 'roo_on_rails/checks/sidekiq/sidekiq'
describe RooOnRails::Checks::Sidekiq::Sidekiq, type: :check do
  describe '#call' do
    let(:gem_output) { '' }
    context 'when sidekiq is enabled' do
      before do
        shell.stub 'bundle list | grep sidekiq', output: gem_output
      end

      context 'when sidekiq gems are installed' do
        let(:gem_output) do
          %{
           * rspec-sidekiq (2.2.0)
           * sidekiq (4.2.9)
           * sidekiq-pro (3.4.5)
           * sidekiq-scheduler (2.1.2)
           * sidekiq-unique-jobs (4.0.18)
          }
        end
        it_expects_check_to_pass

        describe 'Procfile' do
          after do
            File.delete('Procfile')
          end
          let(:procfile_contents) do
            File.read('Procfile')
          end

          context "if there's not a Procfile" do
            it 'adds a Procfile' do
              expect(procfile_contents).not_to include 'web: rails s'
              expect(procfile_contents).to include described_class::WORKER_PROCFILE_LINE
            end
          end
        end
      end

      context 'when sidekiq gems are not installed' do
        it_expects_check_to_fail
      end
    end
  end
end
