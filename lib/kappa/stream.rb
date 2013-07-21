require 'cgi'

module Kappa::V2
  # Streams are video broadcasts that are currently live. They belong to a user and are part of a channel.
  # @see .get Stream.get
  # @see Streams
  # @see Channel
  class Stream
    include Connection
    include Kappa::IdEquality

    # @private
    def initialize(hash)
      @id = hash['_id']
      @broadcaster = hash['broadcaster']
      @game_name = hash['game']
      @name = hash['name']
      @viewer_count = hash['viewers']
      @preview_url = hash['preview']
      @channel = Channel.new(hash['channel'])
      @url = @channel.url
    end

    # Get a live stream by name.
    # @example
    #   s = Stream.get('lagtvmaximusblack')
    #   s.nil?          # => false (stream is live)
    #   s.game_name     # => "StarCraft II: Heart of the Swarm"
    #   s.viewer_count  # => 2403
    # @example
    #   s = Strearm.get('destiny')
    #   s.nil?          # => true (stream is offline)
    # @param stream_name [String] The name of the stream to get. This is the same as the channel or user name.
    # @see Streams.find
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/streams.md#get-streamschannel GET /streams/:channel
    # @return [Stream] A valid `Stream` object if the stream exists and is currently live, `nil` otherwise.
    def self.get(stream_name)
      encoded_name = CGI.escape(stream_name)
      json = connection.get("streams/#{encoded_name}")
      stream = json['stream']
      if json['status'] == 404 || !stream
        nil
      else
        new(stream)
      end
    end

    # Get the owner of this stream.
    # @note This incurs an additional web request.
    # @return [User] The user that owns this stream.
    def user
      User.get(@channel.name)
    end

    # @example
    #   6226912672
    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @example
    #   "fme", "xsplit", "obs", "rebroadcast", "delay", "unknown rtmp"
    # @deprecated This attribute is not present in the V3 API.
    # @return [String] The broadcasting software used for this stream.
    attr_reader :broadcaster
    
    # @example
    #   "Super Meat Boy"
    # @return [String] The name of the game currently being streamed.
    attr_reader :game_name

    # @example
    #   "live_user_lethalfrag"
    # @return [String] The unique Twitch name for this stream.
    attr_reader :name

    # @example
    #   2342
    # @return [Fixnum] The number of viewers currently watching the stream.
    attr_reader :viewer_count

    # @example
    #   "http://static-cdn.jtvnw.net/previews-ttv/live_user_lethalfrag-320x200.jpg"
    # @return [String] URL of a preview screenshot taken from the video stream.
    attr_reader :preview_url

    # @note This does not incur any web requests.
    # @return [Channel] The `Channel` associated with this stream.
    attr_reader :channel

    # @example
    #   "http://www.twitch.tv/lethalfrag" 
    # @return [String] The URL for this stream.
    attr_reader :url
  end

  # Query class used for finding featured streams or streams meeting certain criteria.
  # @see Stream
  class Streams
    include Connection

    # Get a list of streams for a specific game, for a set of channels, or by other criteria.
    # @example
    #   Streams.find(:game => 'League of Legends', :limit => 50)
    # @example
    #   Streams.find(:channel => ['fgtvlive', 'incontroltv', 'destiny'])
    # @example
    #   Streams.find(:game => 'Diablo III', :channel => ['nl_kripp', 'protech'])
    # @param options [Hash] Search criteria.
    # @option options [String/Game/#name] :game Only return streams currently streaming the specified game.
    # @option options [Array<String/Channel/#name>] :channel Only return streams for these channels.
    #   If a channel is not currently streaming, it is omitted. You must specify an array of channels
    #   or channel names. If you want to find the stream for a single channel, see {Stream.get}.
    # @option options [Boolean] :embeddable (nil) If `true`, limit the streams to those that can be embedded. If `false` or `nil`, do not limit.
    # @option options [Boolean] :hls (nil) If `true`, limit the streams to those using HLS (HTTP Live Streaming). If `false` or `nil`, do not limit.
    # @option options [Fixnum] :limit (none) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @see Stream.get
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/streams.md#get-streams GET /streams
    # @raise [ArgumentError] If `options` does not specify a search criteria (`:game`, `:channel`, `:embeddable`, or `:hls`).
    # @return [Array<Stream>] List of streams matching the specified criteria.
    def self.find(options)
      check = options.dup
      check.delete(:limit)
      check.delete(:offset)
      raise ArgumentError, 'options' if check.empty?

      params = {}

      channels = options[:channel]
      if channels
        params[:channel] = channels.map { |channel|
          if channel.respond_to?(:name)
            channel.name
          else
            channel.to_s
          end
        }.join(',')
      end

      game = options[:game]
      if game
        if game.respond_to?(:name)
          params[:game] = game.name
        else
          params[:game] = game.to_s
        end
      end

      if options[:hls]
        params[:hls] = true
      end

      if options[:embeddable]
        params[:embeddable] = true
      end

      return connection.accumulate(
        :path => 'streams',
        :params => params,
        :json => 'streams',
        :class => Stream,
        :limit => options[:limit],
        :offset => options[:offset]
      )
    end

    # Get the list of currently featured (promoted) streams. This includes the list of streams shown on the Twitch homepage.
    # @note There is no guarantee of how many streams are featured at any given time.
    # @example
    #   Streams.featured
    # @example
    #   Streams.featured(:limit => 5)
    # @param options [Hash] Filter criteria.
    # @option options [Boolean] :hls (nil) If `true`, limit the streams to those using HLS (HTTP Live Streaming). If `false` or `nil`, do not limit.
    # @option options [Fixnum] :limit (none) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/streams.md#get-streamsfeatured GET /streams/featured
    # @return [Array<Stream>] List of currently featured streams.
    def self.featured(options = {})
      params = {}

      if options[:hls]
        params[:hls] = true
      end

      return connection.accumulate(
        :path => 'streams/featured',
        :params => params,
        :json => 'featured',
        :sub_json => 'stream',
        :class => Stream,
        :limit => options[:limit],
        :offset => options[:offset]
      )
    end
  end
end
