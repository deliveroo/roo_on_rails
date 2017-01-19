# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/rpm/blob/master/LICENSE for complete details.

# The metric where the mongrel queue time is stored
module NewRelic
  autoload :MetricParser, 'new_relic/metric_parser'
  module MetricParser
    class WebFrontend < NewRelic::MetricParser::MetricParser
      def short_name
        if segments.last == 'Average Queue Time'
          'Mongrel Average Queue Time'
        else
          super
        end
      end
      def legend_name
        'Mongrel Wait'
      end
    end
  end
end
