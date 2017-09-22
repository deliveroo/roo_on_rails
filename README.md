## `roo_on_rails` [![Gem Version](https://badge.fury.io/rb/roo_on_rails.svg)](https://badge.fury.io/rb/roo_on_rails) [![Build Status](https://circleci.com/gh/deliveroo/roo_on_rails.svg?style=shield&circle-token=f8ad2021dfc72fd86850fd0b7224759f34a91281)](https://circleci.com/gh/deliveroo/roo_on_rails) [![Code Climate](https://codeclimate.com/repos/58809e664ab8420081007382/badges/3489b7689ab2e0cf5d61/gpa.svg)](https://codeclimate.com/repos/58809e664ab8420081007382/feed)


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
- [Library usage](#library-usage)
  - [New Relic configuration](#new-relic-configuration)
  - [Rack middleware](#rack-middleware)
  - [Database configuration](#database-configuration)
  - [Sidekiq](#sidekiq)
  - [HireFire (for Sidekiq workers)](#hirefire-for-sidekiq-workers)
  - [Logging](#logging)
  - [Google OAuth authentication](#google-oauth-authentication)
  - [Datadog Integration](#datadog-integration)
  - [Routemaster Client](#routemaster-client)
- [Command features](#command-features)
  - [Usage](#usage)
  - [Description](#description)
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

## Library usage

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

Deliveroo services implement Sidekiq with an _urgency_ pattern. By only having
time-based [SLA](https://en.wikipedia.org/wiki/Service-level_agreement) queue
names (eg. `within5minutes`) we can automatically create incident alerting for
queues which take longer than the time the application needs them to be processed.

When `SIDEKIQ_ENABLED` is set we'll:

- check for the existence of a worker line in your Procfile;
- add SLA style queues to your worker list;
- check for a `HIREFIRE_TOKEN` and if it's set enable SLA based autoscaling;

The following ENV are available:

- `SIDEKIQ_ENABLED`
- `SIDEKIQ_QUEUES` - comma-separated custom queue names; if not specified, default queues are processed which are defined [here](./lib/roo_on_rails/sidekiq/settings.rb). For accurate health reporting and scaling for your custom queue names, you can specify their permitted latency within this variable e.g. `within5seconds,queue-one:10seconds,queue-two:20minutes,queue-three:3hours,queue-four:1day,default`. For non-default queue names that don't follow the `withinXunit` pattern, you will **need** to specify the permitted latency otherwise the initialization will error.
- `SIDEKIQ_THREADS` (default: 25) - Sets sidekiq concurrency value
- `SIDEKIQ_DATABASE_REAPING_FREQUENCY` (default: 10) - For sidekiq processes the
  amount of time in seconds rails will wait before attempting to find and
  recover connections from dead threads

NB. If you are migrating to SLA-based queue names, do not set `SIDEKIQ_ENABLED`
to `true` before your old queues have finished processing (this will prevent
Sidekiq from seeing the old queues at all).

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

For clearer and machine-parseable log output, the Rails logger is replaced by an
extended logger to add context to your logs, which is output as
[logfmt](https://brandur.org/logfmt) key/value pairs along with the log message.

You can use the logger as usual:

```ruby
Rails.logger.info { 'hello world' }
```

From your console, the output will include the timestamp, severity, and message:

```
[2017-08-25 14:34:54.899]    INFO | hello world
```

In production (or whenever the output isn't a TTY), the timestamp is stripped
(as it's provided by the logging pipes) and the output is fully valid `logfmt`:

```
at=INFO msg="hello world"
```

One can also add context using the `with` method:

```ruby
logger.with(a: 1, b: 2) { logger.info 'Stuff' }
# => at=INFO msg=Stuff a=1 b=2
```

```ruby
logger.with(a: 1) { logger.with(b: 2) { logger.info('Stuff') } }
# => at=INFO msg=Stuff a=1 b=2
```

```ruby
logger.with(a: 1, b: 2).info('Stuff')
# => at=INFO msg=Stuff a=1 b=2
```

See the [class documentation](lib/roo_on_rails/logger.rb) for further
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

### Datadog Integration

#### Heroku metrics

To send system metrics to Datadog (CPU, memory usage, HTTP throughput per
status, latency, etc), your application need to send their logs to
[the metrics bridge](https://github.com/deliveroo/heroku-datadog-drain-golang).

This is automatically configured when running `roo_on_rails harness`.

#### Custom application metrics

Sending custom metrics to Datadog through Statsd requires an agent running in
each dyno.
You need to add the buildpack
[`heroku-buildpack-datadog`](https://github.com/deliveroo/heroku-buildpack-datadog).

Once this is done, you can send metrics with e.g.:

```ruby
RooOnRails.statsd.increment('my.metric', tags: 'tag:value')
```

Tags `env:{name}`, `source:{dyno}`, and `app:{name}` will automatically be added
to all your metrics.

The following environment variables are being used.  The default values are fine
except for `STATSD_ENV` which should be set.

- `STATSD_ENV`
- `STATSD_HOST`
- `STATSD_PORT`

These extra required variables are automatically set by Heroku:

- `DYNO`
- `HEROKU_APP_NAME`

### Routemaster Client

When `ROUTEMASTER_ENABLED` is set to `true` we attempt to configure [`routemaster-client`](https://github.com/deliveroo/routemaster-client) on your application. In order for this to happen you need to set the following environment variables:

* `ROUTEMASTER_URL` – the full URL of your Routemaster application (mandatory)
* `ROUTEMASTER_UUID` – the UUID of your application, e.g. `logistics-dashboard` (mandatory)

If you then want to enable the publishing of events onto the event bus, you need to set `ROUTEMASTER_PUBLISHING_ENABLED` to `true` and implement publishers as needed. An example of how to do this is detailed in [`README.routemaster_client.md`](README.routemaster_client.md).

### API Authentication

RooOnRails provides a concern which will make adding rotatable API authentication to your service a breeze:

```ruby
require 'roo_on_rails/concerns/require_api_key'

class ThingController < ActionController::Base
  require_api_key
  # or
  require_api_key(only: :update)
  # or
  require_api_key(only_services: %i(service_1 service_2))

  def index
    # etc
end
```

Keys are specified in environment variables ending with `_CLIENT_KEY`, where the value is a comma separated list of keys which the specified service can authenticate with. This means that if your service has the environment variables:

```
SERVICE_1_CLIENT_KEY=abc123abc123,def456def456
SERVICE_2_CLIENT_KEY=I-never-could-get-the-hang-of-Thursdays
```

Then, for any controller where this concern has been initiated, Basic Authentication will be required and only `service_1:abc123abc123`, `service_1:def456def456` and `service_2:I-never-could-get-the-hang-of-Thursdays` will be allowed access.

## Command features

### Usage

Run the following from your app's top-level directory:

```
roo_on_rails harness
```

That command will sequentially run a number of checks. For it to run successfully, you will need:

- a GitHub API token that can read your GitHub repository's settings placed in `~/.roo_on_rails/github-token`
- the Heroku toolbelt installed and logged in
- admin privileges on the `roo-dd-bridge-production` (this will be addressed eventually)

The command can automatically fix most of the failing checks automatically;
simply run it with the `--fix` flag:

```
roo_on_rails harness --fix
```

To run checks for only one environment, use the `--env` flag:

```
roo_on_rails harness --env staging
```


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
