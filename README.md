# `roo_on_rails` [![Build
Status](https://travis-ci.org/deliveroo/roo_on_rails.svg?branch=master)](https://travis-ci.org/deliveroo/roo_on_rails)[![Code
Climate](https://codeclimate.com/repos/58809e664ab8420081007382/badges/3489b7689ab2e0cf5d61/gpa.svg)](https://codeclimate.com/repos/58809e664ab8420081007382/feed)

A gem that makes following our [guidelines](http://deliveroo.engineering/guidelines/services/) easy.

## Installation

Add this line to your Rails application's Gemfile:

```ruby
gem 'roo_on_rails'
```

And then execute:

    $ bundle


## Features

### New Relic configuration

We enforce configuration of New Relic.

1. Your app must be loaded with a `NEW_RELIC_LICENSE_KEY` environment variable,
   otherwise it will abort.
2. No `new_relic.yml` file may be presentin your app. Overrides to New Relic settings
   through [environment
   variables](https://docs.newrelic.com/docs/agents/ruby-agent/installation-configuration/ruby-agent-configuration)
   is permitted.

No further configuration is required as the gem confiures our standard settings.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/deliveroo/roo_on_rails.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

