# HEAD

Features:

- The `roo_on_rails` test harness now defaults to not fixing issues, and has extra
  `--env` and `--fix` flags
- All checks will now run regardless of previous failure to avoid
  back-and-forthing (#57)
- Friendlier error message when facing Heroku permission errors (#58)


# v1.10.0 (2017-08-11)

Features:

- Asynchronous publishing of events to Routemaster (#56)

# v1.9.0 (2017-08-08)

Features:

- Publish lifecycle events to Routemaster (#19)

# v1.8.1 (2017-07-27)

Features:

- Google OAuth supported in Rails 3 and 4 (#54)

Bug fixes:

- Allow client apps to load middleware (#54)

# v1.8.0 (2017-07-26)

Bug fixes:

- Do not consider 'quiet' workers in the SLA sidekiq metric (#51)

Features:

- Provides a `PLAYBOOK.md` template when detected missing (#42)
- Adds pre-baked Google OAuth support (#44, #49)
- Reports Sidekiq metrics only for queues defined in process (#50)
- Finer-grained Sidekiq configuration (#46)
    - adds 'default' to list of default Sidekiq queues
    - accepts custom Sidekiq queue names and permitted latency values
    - allows environment-specific application checks

Other:

- Fixes the test harness (#48)

# v1.7.0 (2017-07-18)

Features:

- Adds check for Papertrail integration (#43)

# v1.6.0 (2017-07-11)

Features:

- Adds check for a `PLAYBOOK.md` file, which should detail how to deal with
  issues which might occur with the service (#41)

Bug fixes:

- Allow usage of recent versions of `newrelic_rpm` (#38)

# v1.5.0 (2017-06-19)

Features:

- Adds Datadog integration (#35)
- Adds `Sidekiq::MetricsWorker` to publish queue/process metrics (#35)
- Inserts Sidekiq STATSD middleware if Sidekiq Pro is available (#35)

# v1.4.0 (2017-06-05)

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
