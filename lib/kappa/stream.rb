module Kappa
  # @private
  class StreamBase
    include IdEquality

    # TODO: Include in documentation.
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
  # Streams are video broadcasts that are currently live. They have a broadcaster and are part of a channel.
  # @see Channel
  # @see Video
  class Stream < Kappa::StreamBase
    include Connection

    # @private
    def initialize(hash)
      @id = hash['_id']
      @broadcaster = hash['broadcaster']
      @game_name = hash['game']
      @name = hash['name']
      @viewer_count = hash['viewers']
      @preview_url = hash['preview']
      @channel = Channel.new(hash['channel'])
    end

    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @example "fme", "xsplit", "obs"
    # @return [String] The broadcasting software used for this stream.
    attr_reader :broadcaster
    
    # @return [String] The name of the game currently being streamed.
    attr_reader :game_name

    # @return [String] The unique Twitch name for this stream.
    attr_reader :name

    # @return [Fixnum] The number of viewers currently watching the stream.
    attr_reader :viewer_count

    # @return [String] URL of a preview screenshot taken from the video stream.
    attr_reader :preview_url

    # @note This does not incur another web request.
    # @return [Channel] The `Channel` associated with this stream.
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
      if limit && (limit < 100)
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
      if limit && (limit < 100)
        params[:limit] = limit
      else
        params[:limit] = 100
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
