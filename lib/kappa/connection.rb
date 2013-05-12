require 'httparty'
require 'addressable/uri'
require 'securerandom'
require 'json'
require 'singleton'
require 'set'

module Kappa
  # @private
  class ConnectionBase
    include HTTParty

    def initialize(base_url = DEFAULT_BASE_URL)
      @base_url = Addressable::URI.parse(base_url)

      uuid = SecureRandom.uuid
      # TODO: Use current library version.
      @client_id = "Kappa-v1-#{uuid}"

      @last_request_time = Time.now - RATE_LIMIT_SEC
    end

    def get(path, query = nil)
      request_url = @base_url + path

      # Handle non-JSON response
      # Handle invalid JSON
      # Handle non-200 codes

      headers = {
        'Client-ID' => @client_id,
      }.merge(custom_headers)

      response = rate_limit do
        self.class.get(request_url, :headers => headers, :query => query)
      end

      json = response.body
      return JSON.parse(json)
    end

    def accumulate(args)
      path = args[:path]
      params = args[:params]
      json = args[:json]
      sub_json = args[:sub_json]
      klass = args[:class]
      limit = args[:limit]

      objects = []
      ids = Set.new

      paginated(path, params) do |response_json|
        current_objects = response_json[json]
        current_objects.each do |object_json|
          object_json = object_json[sub_json] if sub_json
          object = klass.new(object_json)
          if ids.add?(object.id)
            objects << object
            if objects.count == limit
              return objects
            end
          end
        end

        !current_objects.empty?
      end

      return objects
    end

    def paginated(path, params = {})
      limit = [params[:limit] || 100, 100].min
      offset = params[:offset] || 0

      path_uri = Addressable::URI.parse(path)
      query = { 'limit' => limit, 'offset' => offset }
      path_uri.query_values ||= {}
      path_uri.query_values = path_uri.query_values.merge(query)

      request_url = path_uri.to_s

      params = params.dup
      params.delete(:limit)
      params.delete(:offset)

      json = get(request_url, params)

      # TODO: Hande request retry.
      loop do
        break if json['error'] && (json['status'] == 503)
        break if !yield(json)

        links = json['_links']
        next_url = links['next']

        next_uri = Addressable::URI.parse(next_url)
        offset = next_uri.query_values['offset'].to_i

        total = json['_total']
        break if total && (offset > total)

        request_url = next_url
        json = get(request_url)
      end
    end

  private
    def rate_limit
      delta = Time.now - @last_request_time
      delay = [RATE_LIMIT_SEC - delta, 0].max

      sleep delay if delay > 0

      begin
        return yield
      ensure
        @last_request_time = Time.now
      end
    end

    RATE_LIMIT_SEC = 1
    DEFAULT_BASE_URL = 'https://api.twitch.tv/kraken/'
  end
end

module Kappa::V2
  # @private
  module Connection
    class Impl < Kappa::ConnectionBase
      include Singleton

    private
      def custom_headers
        { 'Accept' => 'application/vnd.twitchtv.v2+json' }
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def connection
      Impl.instance
    end

    module ClassMethods
      def connection
        Impl.instance
      end
    end
  end
end
