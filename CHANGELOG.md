# HEAD

Fixes:

- Use correct GitHub context name for CircleCI (#12)
- Do not depend on sort order for Codecov GitHub contexts (#12)

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

Bug fixes:

- Do not load New Relic in test environments (#2, #3)

# v1.0.0 (2017-01-19)

Features:

- Automatic New Relic configuration, with safeguards (#1)
