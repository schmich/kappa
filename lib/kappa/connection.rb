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
      @client_id = "Kappa-v1-#{uuid}"
    end

    def get(path, query = nil)
      request_url = @base_url + path

      headers = {
        'Client-ID' => @client_id,
      }.merge(custom_headers)

      response = self.class.get(request_url, :headers => headers, :query => query)

      json = response.body
      return JSON.parse(json)
    end

    def accumulate(options)
      path = options[:path]
      params = options[:params] || {}
      json = options[:json]
      sub_json = options[:sub_json]
      klass = options[:class]

      raise ArgumentError, 'json' if json.nil?
      raise ArgumentError, 'path' if path.nil?
      raise ArgumentError, 'class' if klass.nil?

      total_limit = options[:limit]
      page_limit = [total_limit || 100, 100].min
      offset = options[:offset] || 0

      objects = []
      ids = Set.new

      paginated(path, page_limit, offset, params) do |response_json|
        current_objects = response_json[json]
        current_objects.each do |object_json|
          object_json = object_json[sub_json] if sub_json
          object = klass.new(object_json)
          if ids.add?(object.id)
            objects << object
            if !total_limit.nil? && (objects.count == total_limit)
              return objects
            end
          end
        end

        !current_objects.empty? && (current_objects.count >= page_limit)
      end

      return objects
    end

    def paginated(path, limit, offset, params = {})
      path_uri = Addressable::URI.parse(path)
      query = { 'limit' => limit, 'offset' => offset }
      path_uri.query_values ||= {}
      path_uri.query_values = path_uri.query_values.merge(query)

      request_url = path_uri.to_s

      json = get(request_url, params)

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
