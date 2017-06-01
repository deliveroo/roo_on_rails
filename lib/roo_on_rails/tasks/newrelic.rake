namespace :newrelic do
  desc 'Notifies New Relic that a deployment has occurred'
  task notice_deployment: :environment do
    begin
      require 'newrelic_rpm'
      require 'new_relic/cli/command'

      appname = ENV.fetch('NEW_RELIC_APP_NAME')

      Rails.logger.info("Notifying New Relic of deployment to #{appname}")
      NewRelic::Cli::Deployments.new(
        environment: Rails.env.to_s,
        revision: ENV.fetch('SOURCE_VERSION', 'unknown'),
        changelog: '',
        description: '',
        appname: appname,
        user: '',
        license_key: ENV.fetch('NEW_RELIC_LICENSE_KEY')
      ).run
    rescue => e
      Rails.logger.error("Failed to notify New Relic (#{e.class.name}: #{e.message})")
      Rails.logger.info(e.backtrace.take(10).join("\n"))
    end
  end
end
