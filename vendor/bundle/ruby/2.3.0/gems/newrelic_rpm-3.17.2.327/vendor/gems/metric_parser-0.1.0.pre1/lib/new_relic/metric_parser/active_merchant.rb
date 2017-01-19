# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/rpm/blob/master/LICENSE for complete details.

module NewRelic
  autoload :MetricParser, 'new_relic/metric_parser'
  module MetricParser
    class ActiveMerchant < NewRelic::MetricParser::MetricParser

      def is_active_merchant?; true; end

      def is_active_merchant_gateway?
        segments[1] == 'gateway'
      end

      def is_active_merchant_operation?
        segments[1] == 'operation'
      end

      def gateway_name
        # ends in "Gateway" - trim that off
        segments[2][0..-8].titleize
      end

      def operation_name
        segments[2]
      end

      def short_name
        segments[2]
      end

    end
  end
end
