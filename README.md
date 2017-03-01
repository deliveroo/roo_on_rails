## `roo_on_rails` [![Gem Version](https://badge.fury.io/rb/roo_on_rails.svg)](https://badge.fury.io/rb/roo_on_rails) [![Build Status](https://travis-ci.org/deliveroo/roo_on_rails.svg?branch=master)](https://travis-ci.org/deliveroo/roo_on_rails) [![Code Climate](https://codeclimate.com/repos/58809e664ab8420081007382/badges/3489b7689ab2e0cf5d61/gpa.svg)](https://codeclimate.com/repos/58809e664ab8420081007382/feed)

A gem that makes following our [guidelines](http://deliveroo.engineering/guidelines/services/) easy.

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

Run the following from your app's top-level directory:

```
bundle exec roo_on_rails
```

This will run a series of checks of your application's setup, as descirbed
below.


## Features

### App validation

Running the `roo_on_rails` script currently checks for:

- compliant Heroku app naming;
- presence of the Heroku preboot flag.


### New Relic configuration

We enforce configuration of New Relic.

1. Your app must be loaded with a `NEW_RELIC_LICENSE_KEY` environment variable,
   otherwise it will abort.
2. No `new_relic.yml` file may be presentin your app. Overrides to New Relic settings
   through [environment
   variables](https://docs.newrelic.com/docs/agents/ruby-agent/installation-configuration/ruby-agent-configuration)
   is permitted.

No further configuration is required for production apps as the gem configures our standard settings.

However if you have Heroku's [review apps](https://devcenter.heroku.com/articles/github-integration-review-apps) enabled then you will need to update `app.json` so that it lists `NEW_RELIC_LICENSE_KEY` in the `env` section, so that this key is copied from the parent app (only keys listed here will be created on the review app; either generated, if that is specified, or otherwise copied).

More documentation is available [directly from heroku](https://devcenter.heroku.com/articles/github-integration-review-apps#inheriting-config-vars) but the block below has been helpful in other apps:

```json
  "env": {
    "NEW_RELIC_LICENSE_KEY": {
      "description": "The New Relic licence key",
      "required": true
    },
    "SECRET_KEY_BASE": {
      "description": "A secret basis for the key which verifies the integrity of signed cookies.",
      "generator": "secret"
    },
    "RACK_ENV": {
      "description": "The name of the environment for Rack."
    },
    "RAILS_ENV": {
      "description": "The name of the environment for Rails."
    }
  },
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/deliveroo/roo_on_rails.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

