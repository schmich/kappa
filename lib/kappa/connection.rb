require 'httparty'
require 'addressable/uri'
require 'json'
require 'set'

module Twitch
  # @private
  class Connection
    include HTTParty

    def initialize(client_id, base_url = DEFAULT_BASE_URL)
      raise ArgumentError, 'client_id' if !client_id || client_id.empty?
      raise ArgumentError, 'base_url' if !base_url || base_url.empty?

      @client_id = client_id
      @base_url = Addressable::URI.parse(base_url)
    end

    def get(path, query = nil)
      raise ArgumentError, 'path' if !path || path.empty?

      request_url = @base_url + path

      all_headers = {
        'Client-ID' => @client_id,
        'Kappa-Version' => Twitch::VERSION
      }.merge(headers())

      response = self.class.get(request_url, :headers => all_headers, :query => query)

      url = response.request.last_uri.to_s
      status = response.code
      body = response.body

      case status
        when 400...500
          raise Error::ClientError.new("HTTP client error, status #{status}.", url, status, body)
        when 500...600
          raise Error::ServerError.new("HTTP server error, status #{status}.", url, status, body)
        else
          # Ignore, assume success.
      end

      begin
        return JSON.parse(body)
      rescue JSON::ParserError => e
        raise Error::FormatError.new(e, url, status, body)
      end
    end

    def accumulate(options, &block)
      path = options[:path]
      params = options[:params] || {}
      json = options[:json]
      sub_json = options[:sub_json]
      create = options[:create]

      raise ArgumentError, 'json' if json.nil?
      raise ArgumentError, 'path' if path.nil?
      raise ArgumentError, 'create' if create.nil?

      if create.is_a? Class
        klass = create
        create = -> hash { klass.new(hash) }
      end

      total_limit = options[:limit]
      page_limit = [total_limit || 100, 100].min
      offset = options[:offset] || 0

      ids = Set.new
      objects = []
      count = 0

      block ||= -> object {
        objects << object
      }

      paginate(path, page_limit, offset, params) do |response_json|
        current_objects = response_json[json]
        current_objects.each do |object_json|
          object_json = object_json[sub_json] if sub_json
          object = create.call(object_json)
          if ids.add?(object.id)
            count += 1
            block.call(object)
            if count == total_limit
              return block_given? ? nil : objects
            end
          end
        end

        break if current_objects.empty? || (current_objects.count < page_limit)
      end

      return block_given? ? nil : objects
    end

    def paginate(path, limit, offset, params = {})
      path_uri = Addressable::URI.parse(path)
      query = { 'limit' => limit, 'offset' => offset }
      path_uri.query_values ||= {}
      path_uri.query_values = path_uri.query_values.merge(query)

      request_url = path_uri.to_s

      json = get(request_url, params)

      loop do
        break if json['error'] && (json['status'] == 503)
        yield json

        links = json['_links']
        next_url = links['next']

        next_uri = Addressable::URI.parse(next_url)
        offset = next_uri.query_values['offset'].to_i

        total = json['_total']
        break if total && (offset > total)

        request_url = next_url
        json = get(request_url, params)
      end
    end

  private
    DEFAULT_BASE_URL = 'https://api.twitch.tv/kraken/'
  end
end

module Twitch::V2
  # @private
  class Connection < Twitch::Connection
    def headers
      { 'Accept' => 'application/vnd.twitchtv.v2+json' }
    end
  end
end
