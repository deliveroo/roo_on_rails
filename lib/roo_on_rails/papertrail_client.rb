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
      _conn.put('systems/%s.json' % id, system: data).body
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


    # def _get(path, q: {})
    #   _req(path, q:q) do |uri|
    #     Net::HTTP::Get.new(uri)
    #   end
    # end

    # def _post(path, q: {}, body:)
    #   _req(path, q:q) do |uri|
    #     Net::HTTP::Post.new(uri).tap do |req|
    #       req['Content-Type'] = 'application/json'
    #       req.body = JSON.dump(body)
    #     end
    #   end
    # end

    # def _req(path, q: {})
    #   uri = _api_url.dup
    #   uri.path = uri.path + path
    #   uri.query = Rack::Utils.build_query(q) if q.any?
      
    #   req = yield uri
    #   req['X-Papertrail-Token'] = @token

    #   response = _http.request(req)
    #   if response['content-type'] =~ %r{^application/json}
    #     body = JSON.parse(response.body)
    #   else
    #     body = response.body
    #   end

    #   case response.code.to_i
    #   when 200..299 then # do nothing
    #   when 400..499 then raise 
    #   body
    # end

    # def _http
    #   http = Net::HTTP.new(_api_url.host, _api_url.port)
    #   http.use_ssl = true
    #   http.start
    # end

    def _api_url
      @_api_url = URI.parse('https://papertrailapp.com/api/v1')
    end
  end
end
