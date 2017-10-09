require 'faraday'
require 'faraday_middleware'
require 'json'

module RooOnRails
  class PapertrailClient
    def initialize(token:)
      @token = token
    end

    def list_destinations
      _conn.get('destinations.json').body
    end

    def list_systems
      _conn.get('systems.json').body
    end

    def get_system(id)
      _conn.get('systems/%s.json' % id).body
    end

    def update_system(id, data)
      _conn.put('systems/%s.json' % id, system: { name: data }).body
    end

    # private

    def _conn
      @_conn ||= Faraday.new(_api_url, headers: { 'X-Papertrail-Token' => @token }) do |conf|
        conf.response :mashify
        conf.response :json
        conf.response :raise_error
        # conf.response :logger
        conf.request :json

        conf.adapter Faraday.default_adapter
      end
    end

    def _api_url
      @_api_url = URI.parse('https://papertrailapp.com/api/v1')
    end
  end
end
