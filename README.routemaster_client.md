## Using the Routemaster Client feature

[`routemaster-client`](https://github.com/deliveroo/routemaster-client) comes as a dependency of `roo_on_rails` with a basic implementation of lifecycle event publishers.

This code example assumes that you are using the latest version of the [`roo_on_rails`](roo_on_rails) gem and that you have set the correct environment variables for Routemaster Client to work on your app, as explained in the main [`README.md`](roo_on_rails#routemaster-client) file.

It also assumes that your app has an API for the resources you want to publish lifecycle events for, with matching routes and an `API_HOST` environment variable set.

### Setup lifecycle events for your models

We will most likely want to publish lifecycle events for several models, so to write slightly less code let's create a model concern first:

```ruby
# app/models/concerns/routemaster_lifecycle_events.rb
require 'roo_on_rails/routemaster/lifecycle_events'

module RoutemasterLifecycleEvents
  extend ActiveSupport::Concern
  include RooOnRails::Routemaster::LifecycleEvents

  included do
    publish_lifecycle_events
  end
end
```

Then let's include this concern to the relevant model(s):

```ruby
# app/models/order.rb
class Order < ApplicationRecord
  include RoutemasterLifecycleEvents

  # ...
end
```

And another one for the example:

```ruby
# app/models/rider.rb
class Rider < ApplicationRecord
  include RoutemasterLifecycleEvents

  # ...
end
```

### Create publishers for lifecycle events

We have now configured our models to publish lifecycle events to Routemaster, but it won't send anything until you have enabled publishing and created matching publishers. Let's start with creating a `BasePublisher` that we can then inherit from:

```ruby
# app/publishers/base_publisher.rb
require 'roo_on_rails/routemaster/publisher'

class BasePublisher < RooOnRails::Routemaster::Publisher
  include Rails.application.routes.url_helpers

  def publish?
    noop? || model.new_record? || model.previous_changes.any?
  end
end
```

Then create a publisher for each model with lifecycle events enabled:

```ruby
# app/publishers/order_publisher.rb
class OrderPublisher < BasePublisher
  def url
    api_order_url(model, host: ENV.fetch('API_HOST'), protocol: 'https')
  end
end
```

and

```ruby
# app/publishers/rider_publisher.rb
class RiderPublisher < BasePublisher
  def url
    api_rider_url(model, host: ENV.fetch('API_HOST'), protocol: 'https')
  end
end
```

### Register the publishers with Routemaster

The final step is to tell Routemaster that these publishers exist, so that it can listen to their events. We're going to do this in an initialiser:

```ruby
# config/initilizers/routemaster.rb
require 'roo_on_rails/routemaster/publishers'

PUBLISHERS = [
  OrderPublisher,
  RiderPublisher
].freeze

PUBLISHERS.each do |publisher|
  model_class = publisher.to_s.gsub("Publisher", "").constantize
  RooOnRails::Routemaster::Publishers.register(publisher, model_class: model_class)
end
```

We should now be all set for our app to publish lifecycle events for `orders` and `riders` onto the event bus, so that other apps can listen to them.
