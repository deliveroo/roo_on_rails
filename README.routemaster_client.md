## Using the Routemaster Client feature

[`routemaster-client`](https://github.com/deliveroo/routemaster-client) comes as a dependency of `roo_on_rails` with a basic implementation of lifecycle event publishers.

This code example assumes that you are using the latest version of the [`roo_on_rails`](roo_on_rails) gem and that you have set the correct environment variables for Routemaster Client to work on your app, as explained in the main [`README.md`](roo_on_rails#routemaster-client) file.

It also assumes that your app has an API for the resources you want to publish lifecycle events for, with matching routes and an `API_HOST` environment variable set.

### Setup lifecycle events for your models

You can use publish events on create, update, and destroy by including the `PublishLifecycleEvents` module:

```ruby
# app/models/order.rb
require 'roo_on_rails/routemaster/publish_lifecycle_events'

class Order < ApplicationRecord
  include RooOnRails::Routemaster::PublishLifecycleEvents

  # ...
end
```

If you need more control over which events are published you can use the base module `LifecycleEvents` and specify them explicitly:

```ruby
# app/models/rider.rb
require 'roo_on_rails/routemaster/publish_lifecycle_events'

class Rider < ApplicationRecord
  include RooOnRails::Routemaster::LifecycleEvents

  publish_lifecycle_events :create, :destroy

  # ...
end
```

### Create publishers for lifecycle events

We have now configured our models to publish lifecycle events to Routemaster, but it won't send anything until you have enabled publishing and created matching publishers. Let's start with creating an `ApplicationPublisher` that we can use as our default.

```ruby
# app/publishers/application_publisher.rb
require 'roo_on_rails/routemaster/publisher'

class ApplicationPublisher < RooOnRails::Routemaster::Publisher
  include Rails.application.routes.url_helpers

  def url
    url_helper = :"api_#{model.class.name.underscore}_url"
    public_send(url_helper, model.id, host: ENV.fetch('API_HOST'), protocol: 'https')
  end

  # Add your method overrides here if needed
end
```

If different behaviour is needed for specific models then you can override the defaults in their publishers:

```ruby
# app/publishers/order_publisher.rb
class OrderPublisher < ApplicationPublisher
  def async?
    true
  end
end
```

and

```ruby
# app/publishers/rider_publisher.rb
class RiderPublisher < ApplicationPublisher
  def topic
    'a_different_rider_topic'
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

RooOnRails::Routemaster::Publishers.register_default(ApplicationPublisher)
PUBLISHERS.each do |publisher|
  model_class = publisher.to_s.gsub("Publisher", "").constantize
  RooOnRails::Routemaster::Publishers.register(publisher, model_class: model_class)
end
```

We should now be all set for our app to publish lifecycle events for all our models onto the event bus, with special behaviour for `orders` and `riders`, so that other apps can listen to them.
