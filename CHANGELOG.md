# HEAD

Features:

- Adds `newrelic:notice_deployment` rake task (#32)
- Adds Heroku/Datadog integration checks (#33)
- Supports Rails apps without ActiveRecord (#26)

Fixes:

- `roo_on_rails` command only loads the checks harness if necessary (#30)
- Upgrades outdated `platform-api` gem (#31)

# v1.3.1 (2017-05-05)

Features:

- Adds Rails 5.1 support (#25)

Fixes:

- Documentation (#23, #24)

# v1.3.0 (2017-04-28)

Features:

- Sets database statement timeout to 200ms by default (#13).
- Sets migration statement timeout to 10s by default (#16, #17)
- Adds Sidekiq and Hirefire (workers) integration (#11)
- Adds the ability to tag logs with key/value pairs (#20, #21)

Fixes:

- Use correct GitHub context name for CircleCI (#12)
- Do not depend on sort order for Codecov GitHub contexts (#12)
- Do not add `Rack::SslEnforcer` middleware in test environment (#15)
- Fix for "undefined constant: RooOnRails::Rack::Timeout" (#18)
- Use correct class name in Sidekiq auto-scaling metric (#22)

# v1.2.0 (2017-03-21)

Features:

- Add `Rack::Timeout`, `Rack::SslEnforcer`, `Rack::Deflater` middleware when
  loaded (#7).
- `roo_on_rails` command now checks for Github branch protection (#8).

Fixes:

- Wider build matrix; now with Rails 3, 4, 5 compatibility on various Rubies
  (#6, #9).

# v1.1.0 (2017-02-20)

Features:

- `roo_on_rails` command, with basic Heroku app checks (#4)

# v1.0.1 (2017-01-20)

Fixes:

- Do not load New Relic in test environments (#2, #3)

# v1.0.0 (2017-01-19)

Features:

- Automatic New Relic configuration, with safeguards (#1)
