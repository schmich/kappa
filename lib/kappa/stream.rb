require 'set'

module Kappa
  class StreamBase
    include IdEquality

    def initialize(arg, connection)
      @connection = connection

      case arg
        when Hash
          @live = !arg.empty?
          parse(arg)
        when String
          json = @connection.get("streams/#{arg}")
          stream = json['stream']
          if stream
            @live = true
            parse(stream)
          else
            @live = false
          end
        when NilClass
          @live = false
        else
          raise ArgumentError
      end
    end

    def live?
      @live
    end
  end
end

module Kappa::V3
  class Stream < Kappa::StreamBase
    def initialize(arg, connection = Connection.instance)
      super(arg, connection)
    end

  private
    def parse(hash)
    end
  end
end

module Kappa::V2
  class Stream < Kappa::StreamBase
    def initialize(arg, connection = Connection.instance)
      super(arg, connection)
    end

    attr_reader :id
    attr_reader :broadcaster
    attr_reader :game_name
    attr_reader :name
    attr_reader :viewer_count
    attr_reader :preview_url
    attr_reader :channel

  private
    def parse(hash)
      @id = hash['_id']
      @broadcaster = hash['broadcaster']
      @game_name = hash['game']
      @name = hash['name']
      @viewer_count = hash['viewers']
      @preview_url = hash['preview']
      @channel = Channel.new(hash['channel'], @connection)
    end
  end

  class Streams
    def self.all
    end

    #
    # GET /streams
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/streams.md
    # :game (single, string), :channel (string array), :limit (int), :offset (int), :embeddable (bool), :hls (bool)
    # TODO: Support Kappa::Vx::Game object for the :game param.
    # TODO: Support Kappa::Vx::Channel object for the :channel param.
    #
    def self.where(params = {})
      limit = params[:limit] || 0

      params = params.dup
      if params[:channel]
        params[:channel] = params[:channel].join(',')
      end

      streams = []
      ids = Set.new

      connection = Connection.instance
      connection.paginated('streams', params) do |json|
        current_streams = json['streams']
        current_streams.each do |stream_json|
          stream = Stream.new(stream_json, connection)
          if ids.add?(stream.id)
            streams << stream
            if streams.count == limit
              return streams
            end
          end
        end

        !current_streams.empty?
      end

      streams
    end

    #
    # GET /streams/featured
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/streams.md#get-streamsfeatured
    #
    def self.featured(params = {})
      limit = params[:limit] || 0

      streams = []
      ids = Set.new

      connection = Connection.instance
      connection.paginated('streams/featured', params) do |json|
        current_streams = json['featured']
        current_streams.each do |featured_json|
          # TODO: Capture more information from the featured_json structure (need a FeaturedStream class?)
          stream_json = featured_json['stream']
          stream = Stream.new(stream_json, connection)
          if ids.add?(stream.id)
            streams << stream
            if streams.count == limit
              return streams
            end
          end
        end

        !current_streams.empty?
      end

      streams
    end
  end
end
