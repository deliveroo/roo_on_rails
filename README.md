## `roo_on_rails` [![Gem Version](https://badge.fury.io/rb/roo_on_rails.svg)](https://badge.fury.io/rb/roo_on_rails) [![Build Status](https://travis-ci.org/deliveroo/roo_on_rails.svg?branch=master)](https://travis-ci.org/deliveroo/roo_on_rails) [![Code Climate](https://codeclimate.com/repos/58809e664ab8420081007382/badges/3489b7689ab2e0cf5d61/gpa.svg)](https://codeclimate.com/repos/58809e664ab8420081007382/feed)


`roo_on_rails` is:

1. A library that extends Rails (as a set of Railties) and auto-configures common
   dependencies.
2. A command that checks whether an application's Github repository and Heroku
   instanciations are compliant.

... packaged into a gem, to make following our
[guidelines](http://deliveroo.engineering/guidelines/services/) easy.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Installation](#installation)
- [Usage](#usage)
- [Library features](#library-features)
    - [New Relic configuration](#new-relic-configuration)
    - [Rack middleware](#rack-middleware)
    - [Database configuration](#database-configuration)
    - [Sidekiq](#sidekiq)
    - [HireFire Workers](#hirefire-workers)
    - [Logging](#logging)
    - [Google Oauth](#google-oauth)
- [Command features](#command-features)
- [Contributing](#contributing)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Installation

Add this line at the top of your Rails application's Gemfile:

```ruby
gem 'roo_on_rails'
```

Remove the following gems from your Gemfile, as they're provided and configured
by `roo_on_rails`:

- `dotenv`
- `newrelic_rpm`

Remove the following configuration files:

- `newrelic.yml` or `config/newrelic.yml`

Also remove any other gem-specific configuration from your repository.

And then execute:

    $ bundle

Then re-run your test suite to make sure everything is shipshape.

## Usage

## Configuration and usage

### New Relic configuration

We enforce configuration of New Relic.

1. Your app must be loaded with a `NEW_RELIC_LICENSE_KEY` environment variable,
   otherwise it will abort.
2. No `new_relic.yml` file may be presentin your app. Overrides to New Relic settings
   through [environment
   variables](https://docs.newrelic.com/docs/agents/ruby-agent/installation-configuration/ruby-agent-configuration)
   is permitted.
3. The `NEW_RELIC_APP_NAME` environment variable must be defined
   such that the app will be properly registered in New Relic.

No further configuration is required for production apps as the gem configures
our standard settings.

### Rack middleware

We'll insert the following middlewares into the rails stack:

1. `Rack::Timeout`: sets a timeout for all requests. Use `RACK_SERVICE_TIMEOUT`
   (default 15) and `RACK_WAIT_TIMEOUT` (default 30) to customise.
2. `Rack::SslEnforcer`: enforces HTTPS.
3. `Rack::Deflater`: compresses responses from the application, can be disabled
   with `ROO_ON_RAILS_RACK_DEFLATE` (default: 'YES').
4. Optional middlewares for Google Oauth2 (more below).

### Database configuration

The database statement timeout will be set to a low value by default. Use
`DATABASE_STATEMENT_TIMEOUT` (milliseconds, default 200) to customise.

For database creation and migration (specifically the `db:create`, `db:migrate`,
`db:migrate:down` and `db:rollback` tasks) a much higher statement timeout is
set by default. Use `MIGRATION_STATEMENT_TIMEOUT` (milliseconds, default 10000)
to customise.

_Note: This configuration is not supported in Rails 3 and will be skipped. Set
statement timeouts directly in the database._

### Sidekiq

When `SIDEKIQ_ENABLED` is set we'll:

- check for the existence of a worker line in your Procfile;
- add SLA style queues to your worker list;
- check for a `HIREFIRE_TOKEN` and if it's set enable SLA based autoscaling;

The following ENV are available:

- `SIDEKIQ_ENABLED`
- `SIDEKIQ_THREADS` (default: 25) - Sets sidekiq concurrency value
- `SIDEKIQ_DATABASE_REAPING_FREQUENCY` (default: 10) - For sidekiq processes the
  amount of time in seconds rails will wait before attempting to find and
  recover connections from dead threads

### HireFire (for Sidekiq workers)

When `HIREFIRE_TOKEN` is set an endpoint will be mounted at `/hirefire` that
reports the required worker count as a function of queue latency. By default we
add queue names in the style 'within1day', so if we notice an average latency in
that queue of more than an set threshold we'll request one more worker. If we
notice less than a threshold we'll request one less worker. These settings can
be customised via the following ENV variables

- `WORKER_INCREASE_THRESHOLD` (default 0.5)
- `WORKER_DECREASE_THRESHOLD` (default 0.1)

When setting the manager up in the HireFire web ui, the following settings must
be used:

- name: 'worker'
- type: 'Worker.HireFire.JobQueue'
- ratio: 1
- decrementable: 'true'

### Logging

For clearer and machine-parseable log output, there in an extension to be able
to add context to your logs which is output as
[logfmt](https://brandur.org/logfmt) key/value pairs after the log message.

```ruby
# application.rb

require 'roo_on_rails/context_logging'

class Application < Rails::Application

  # add this block somewhere within the application class
  logger = config.logger
  if logger.nil?
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
  end
  logger = ActiveSupport::TaggedLogging.new(logger) unless logger.respond_to?(:tagged)
  config.logger = RooOnRails::ContextLogging.new(logger)

end
```

You can then add context using the `with` method:

```ruby
logger.with(a: 1, b: 2) { logger.info 'Stuff' }
logger.with(a: 1) { logger.with(b: 2) { logger.info('Stuff') } }
logger.with(a: 1, b: 2).info('Stuff')
```

See the [class documentation](lib/roo_on_rails/context_logging.rb) for further
details.

### Google OAuth authentication

When `GOOGLE_AUTH_ENABLED` is set to true we inject a `Omniauth` Rack middleware
with a pre-configured strategy for Google Oauth2.

Parameters:

- `GOOGLE_AUTH_CLIENT_ID` and `GOOGLE_AUTH_CLIENT_SECRET` (mandatory)
- `GOOGLE_AUTH_PATH_PREFIX` (optional, defaults to `/auth`)
- `GOOGLE_AUTH_CONTROLLER` (optional, defaults to `sessions`)

This feature is bring-your-own-controller — it won't magically protect your
application.

A simple but secure example is detailed in `README.google_oauth2.md`.


## Command features

### Usage

Run the following from your app's top-level directory:

```
bundle exec roo_on_rails
```

You will (currently) need to have admin privileges on the
`roo-dd-bridge-production` application for this to work. This will be addressed
eventually.


### Description

Running the `roo_on_rails` command currently checks for:

- the presence of `PLAYBOOK.md`
- compliant Heroku app naming;
- presence of the Heroku preboot flag;
- correct Github master branch protection;
- integration with the Heroku-Datadog metrics bridge (for CPU, memory, request
  throughput data);
- integration with Papertrail;
- correct Sidekiq configuration.

The command is designed to fix issues in many cases.


## Contributing

Pull requests are welcome on GitHub at
`https://github.com/deliveroo/roo_on_rails`.


## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
