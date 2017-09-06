require 'active_support/concern'
require 'roo_on_rails/routemaster/lifecycle_events'

module RooOnRails
  module Routemaster
    module PublishLifecycleEvents
      extend ActiveSupport::Concern
      include LifecycleEvents

      included(&:publish_lifecycle_events)
    end
  end
end
