require 'cgi'

module Twitch::V5
  # Streams are video broadcasts that are currently live. They belong to a user and are part of a channel.
  # @see Streams#get Streams#get
  # @see Streams#find Streams#find
  # @see Streams#featured Streams#featured
  # @see Streams
  # @see Channel
  class Stream
    include Twitch::IdEquality

    # @private
    def initialize(hash, query)
      @query = query
      @id = hash['_id']
      @game_name = hash['game']
      @viewer_count = hash['viewers']
      @video_height = hash['video_height']
      @average_fps = hash['average_fps']
      @delay = hash['delay']
      @created_at = hash['created_at']
      @is_playlist = hash['is_playlist']
      @preview_url = hash['preview']
      @channel = Channel.new(hash['channel'], @query)
      @name = @channel.name
      @url = @channel.url
    end

    # Whether the stream is a playlist or not.
    # @return [Boolean] `true` if the stream is a playlist, `false` otherwise.
    def playlist?
      @playlist
    end

    # Get the owner of this stream.
    # @note This incurs an additional web request.
    # @return [User] The user that owns this stream.
    def user
      @query.users.get(@channel.name)
    end

    # @example
    #   6226912672
    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @example
    #   "Super Meat Boy"
    # @return [String] The name of the game currently being streamed.
    attr_reader :game_name

    # @example
    #   2342
    # @return [Fixnum] The number of viewers currently watching the stream.
    attr_reader :viewer_count

    # @example
    #   720
    # @return [Fixnum] The height of the video.
    attr_reader :video_height

    # @example
    #   60
    # @return [Fixnum] The average FPS of the stream.
    attr_reader :average_fps

    # @example
    #   0
    # @return [Fixnum] The delay of the stream.
    attr_reader :delay

    # @example
    #   "2016-12-14T22:49:56Z"
    # @return [Time] The date and time the stream was created.
    attr_reader :created_at

    # @example
    #   "http://static-cdn.jtvnw.net/previews-ttv/live_user_lethalfrag-320x200.jpg"
    # @return [String] URL of a preview screenshot taken from the video stream.
    attr_reader :preview_url

    # @note This does not incur any web requests.
    # @return [Channel] The `Channel` associated with this stream.
    attr_reader :channel

    # @example
    #   "live_user_lethalfrag"
    # @return [String] The unique Twitch name for this stream.
    attr_reader :name

    # @example
    #   "http://www.twitch.tv/lethalfrag"
    # @return [String] The URL for this stream.
    attr_reader :url
  end

  # Site-wide stream summary statistics.
  # @see Streams#summary Streams#summary
  class StreamSummary
    # @private
    def initialize(hash)
      @viewer_count = hash['viewers']
      @channel_count = hash['channels']
    end

    # @example
    #   194774
    # @return [Fixnum] The sum of all viewers across all live streams.
    attr_reader :viewer_count

    # @example
    #   4144
    # @return [Fixnum] The count of all channels currently streaming.
    attr_reader :channel_count
  end

  # Query class for finding featured streams or streams meeting certain criteria.
  # @see Stream
  class Streams
    # @private
    def initialize(query)
      @query = query
    end

    # Get a live stream by name.
    # @example
    #   s = Twitch.streams.get('lagtvmaximusblack')
    #   s.nil?          # => false (stream is live)
    #   s.game_name     # => "StarCraft II: Heart of the Swarm"
    #   s.viewer_count  # => 2403
    # @example
    #   s = Twitch.streams.get('destiny')
    #   s.nil?          # => true (stream is offline)
    # @param stream_name [String] The name of the stream to get. This is the same as the channel or user name.
    # @see #find
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/streams.md#get-streamschannel GET /streams/:channel
    # @return [Stream] A valid `Stream` object, if the stream exists and is live.
    # @return [nil] If the stream does not exist or is not live.
    def get(stream_name)
      name = CGI.escape(stream_name)
      query = { login: name }
      user_json = @query.connection.get('users', query)
      userhash = user_json['users'][0]
      id = userhash['_id']
      # HTTP 422 can happen if the stream is associated with a Justin.tv account.
      Twitch::Status.map(404 => nil, 422 => nil) do
        json = @query.connection.get("streams/#{id}")
        stream = json['stream']
        stream.nil? ? nil : Stream.new(stream, @query)
      end
    end

    # Get all currently live streams sorted by descending viewer count.
    # @example
    #   Twitch.streams.all
    # @example
    #   Twitch.streams.all(:offset => 100, :limit => 10)
    # @example
    #   Twitch.streams.all do |stream|
    #     next if stream.viewer_count < 1000
    #     puts stream.url
    #   end
    # @param options [Hash] Limit criteria.
    # @option options [Fixnum] :limit (nil) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @yield Optional. If a block is given, each stream is yielded.
    # @yieldparam [Stream] stream Current stream.
    # @see #get
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/streams.md#get-streams GET /streams
    # @return [Array<Stream>] Currently live streams, sorted by descending viewer count, if no block is given.
    # @return [nil] If a block is given.
    def all(options = {}, &block)
      return @query.connection.accumulate(
        :path => 'streams',
        :json => 'streams',
        :create => -> hash { Stream.new(hash, @query) },
        :limit => options[:limit],
        :offset => options[:offset],
        &block
      )
    end

    # Get streams for a specific game, for a set of channels, or by other criteria, sorted by descending viewer count.
    # @example
    #   Twitch.streams.find(:game => 'League of Legends', :limit => 50)
    # @example
    #   Twitch.streams.find(:channel => ['fgtvlive', 'incontroltv', 'destiny'])
    # @example
    #   Twitch.streams.find(:game => 'Diablo III', :channel => ['nl_kripp', 'protech'])
    # @example
    #   Twitch.streams.find(:game => 'League of Legends') do |stream|
    #     next if stream.viewer_count < 1000
    #     puts stream.url
    #   end
    # @param options [Hash] Search criteria.
    # @option options [String, Game, #name] :game Only return streams currently streaming the specified game.
    # @option options [Array<String, Channel, #name>] :channel Only return streams for these channels.
    #   If a channel is not currently streaming, it is omitted. You must specify an array of channels
    #   or channel names. If you want to find the stream for a single channel, see {Streams#get}.
    # @option options [Boolean] :embeddable (nil) If `true`, limit the streams to those that can be embedded. If `false` or `nil`, do not limit.
    # @option options [Boolean] :hls (nil) If `true`, limit the streams to those using HLS (HTTP Live Streaming). If `false` or `nil`, do not limit.
    # @option options [Fixnum] :limit (nil) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @yield Optional. If a block is given, each stream found is yielded.
    # @yieldparam [Stream] stream Current stream.
    # @see #get
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/streams.md#get-streams GET /streams
    # @raise [ArgumentError] If `options` does not specify a search criteria (`:game`, `:channel`, `:embeddable`, or `:hls`).
    # @raise [ArgumentError] If `:channel` is not an array.
    # @return [Array<Stream>] Streams matching the specified criteria, sorted by
    #   descending viewer count, if no block is given.
    # @return [nil] If a block is given.
    def find(options, &block)
      check = options.dup
      check.delete(:limit)
      check.delete(:offset)
      raise ArgumentError, 'options' if check.empty?

      params = {}

      channels = options[:channel]
      if channels
        if !channels.respond_to?(:map)
          raise ArgumentError, ':channel'
        end

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

      return @query.connection.accumulate(
        :path => 'streams',
        :params => params,
        :json => 'streams',
        :create => -> hash { Stream.new(hash, @query) },
        :limit => options[:limit],
        :offset => options[:offset],
        &block
      )
    end

    # Get the currently featured (promoted) streams. This includes the streams shown on the Twitch homepage.
    # @note There is no guarantee of how many streams are featured at any given time.
    # @example
    #   Twitch.streams.featured
    # @example
    #   Twitch.streams.featured(:limit => 5)
    # @example
    #   Twitch.streams.featured do |stream|
    #     next if stream.viewer_count < 1000
    #     puts stream.url
    #   end
    # @param options [Hash] Filter criteria.
    # @option options [Boolean] :hls (nil) If `true`, limit the streams to those using HLS (HTTP Live Streaming). If `false` or `nil`, do not limit.
    # @option options [Fixnum] :limit (nil) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @yield Optional. If a block is given, each featured stream is yielded.
    # @yieldparam [Stream] stream Current stream.
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/streams.md#get-streamsfeatured GET /streams/featured
    # @return [Array<Stream>] Featured streams, if no block is given.
    # @return [nil] If a block is given.
    def featured(options = {}, &block)
      params = {}

      if options[:hls]
        params[:hls] = true
      end

      return @query.connection.accumulate(
        :path => 'streams/featured',
        :params => params,
        :json => 'featured',
        :sub_json => 'stream',
        :create => -> hash { Stream.new(hash, @query) },
        :limit => options[:limit],
        :offset => options[:offset],
        &block
      )
    end

    # Get site-wide stream summary statistics.
    # @example
    #   summary = Twitch.streams.summary
    #   summary.viewer_count  # => 194774
    #   summary.channel_count # => 4144
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/streams.md#gedt-streamssummary GET /streams/summary
    # @return [StreamSummary] Stream summary statistics.
    def summary
      json = @query.connection.get('streams/summary')
      StreamSummary.new(json)
    end
  end
end
