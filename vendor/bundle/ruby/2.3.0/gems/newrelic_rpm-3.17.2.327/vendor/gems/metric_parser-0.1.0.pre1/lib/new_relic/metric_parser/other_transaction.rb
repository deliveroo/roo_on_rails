# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/rpm/blob/master/LICENSE for complete details.

# OtherTransaction metrics must have at least three segments: /OtherTransaction/<task>/*
# Task is "Background", "Resque", "DelayedJob" etc.
module NewRelic
  autoload :MetricParser, 'new_relic/metric_parser'
  module MetricParser
    class OtherTransaction < NewRelic::MetricParser::MetricParser

      def is_transaction?
        true
      end
      def task
        segments[1]
      end

      def developer_name
        segments[2..-1].join(NewRelic::MetricParser::MetricParser::SEPARATOR)
      end

      def short_name
        developer_name
      end

      def drilldown_url(metric_id)
        {:controller => '/v2/background_tasks', :action => 'index', :task => task, :anchor => "id=#{metric_id}"}
      end

      def path
        segments[2..-1].join "/"
      end

      def summary_metrics
        if segments.size > 2
          %W[OtherTransaction/#{task}/all OtherTransaction/all]
        else
          []
        end
      end
    end
  end
end
