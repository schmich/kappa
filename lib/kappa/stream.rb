module Kappa
  class StreamBase
    include IdEquality

    def self.get(stream_name)
      json = connection.get("streams/#{stream_name}")
      stream = json['stream']
      if json['status'] == 404 || !stream
        nil
      else
        new(stream)
      end
    end
  end
end

module Kappa::V2
  class Stream < Kappa::StreamBase
    include Connection

    def initialize(hash)
      @id = hash['_id']
      @broadcaster = hash['broadcaster']
      @game_name = hash['game']
      @name = hash['name']
      @viewer_count = hash['viewers']
      @preview_url = hash['preview']
      @channel = Channel.new(hash['channel'])
    end

    attr_reader :id
    attr_reader :broadcaster
    attr_reader :game_name
    attr_reader :name
    attr_reader :viewer_count
    attr_reader :preview_url
    attr_reader :channel
  end

  class Streams
    include Connection

    def self.all
    end

    #
    # GET /streams
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/streams.md
    # :game (single, string), :channel (string array), :limit (int), :offset (int), :embeddable (bool), :hls (bool)
    # TODO: Support Kappa::Vx::Game object for the :game param.
    # TODO: Support Kappa::Vx::Channel object for the :channel param.
    #
    def self.where(args)
      check = args.dup
      check.delete(:limit)
      check.delete(:offset)
      raise ArgumentError if check.empty?

      params = {}

      if args[:channel]
        params[:channel] = args[:channel].join(',')
      end

      if args[:game]
        params[:game] = args[:game]
      end

      limit = args[:limit]
      if limit && (limit < 25)
        params[:limit] = limit
      else
        params[:limit] = 100
        limit = 0
      end

      return connection.accumulate(
        :path => 'streams',
        :params => params,
        :json => 'streams',
        :class => Stream,
        :limit => limit
      )
    end

    #
    # GET /streams/featured
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/streams.md#get-streamsfeatured
    #
    def self.featured(args = {})
      params = {}

      limit = args[:limit]
      if limit && (limit < 25)
        params[:limit] = limit
      else
        params[:limit] = 25
        limit = 0
      end

      return connection.accumulate(
        :path => 'streams/featured',
        :params => params,
        :json => 'featured',
        :sub_json => 'stream',
        :class => Stream,
        :limit => limit
      )
    end
  end
end
