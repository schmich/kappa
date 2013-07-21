require 'cgi'
require 'time'

module Kappa::V2
  # @private
  class ChannelProxy
    def initialize(name, display_name)
      @name = name
      @display_name = display_name
    end

    attr_reader :name
    attr_reader :display_name

    include Proxy

    proxy {
      Channel.get(@name)
    }
  end

  # Videos are broadcasts or highlights owned by a channel. Broadcasts are unedited
  # videos that are saved after a streaming session. Highlights are videos edited from
  # broadcasts by the channel's owner.
  # @see .get Video.get
  # @see Videos
  # @see Channel
  class Video
    include Connection
    include Kappa::IdEquality

    # @private
    def initialize(hash)
      @id = hash['_id']
      @title = hash['title']
      @recorded_at = Time.parse(hash['recorded_at']).utc
      @url = hash['url']
      @view_count = hash['views']
      @description = hash['description']
      @length = hash['length']
      @game_name = hash['game']
      @preview_url = hash['preview']
      @embed_html = hash['embed']

      @channel = ChannelProxy.new(
        hash['channel']['name'],
        hash['channel']['display_name']
      )
    end

    # Get a video by ID.
    # @example
    #   v = Video.get('a396294648')
    # @param id [String] The ID of the video to get.
    # @raise [ArgumentError] If `id` is `nil` or blank.
    # @return [Video] A valid `Video` object if the video exists, `nil` otherwise.
    def self.get(id)
      raise ArgumentError if !id || id.strip.empty?

      encoded_id = CGI.escape(id)
      json = connection.get("videos/#{encoded_id}")
      if !json || json['status'] == 404
        nil
      else
        new(json)
      end
    end

    # @note This is a `String`, not a `Fixnum` like most other object IDs.
    # @example
    #   "a396294648"
    # @return [String] Unique Twitch ID for this video.
    attr_reader :id

    # @example
    #   "DreamHack Open Stockholm 26-27 April"
    # @return [String] Title of this video. This is seen on the video's page.
    attr_reader :title

    # @example
    #   2013-04-27 09:37:30 UTC
    # @return [Time] When this video was recorded (UTC).
    attr_reader :recorded_at

    # @example
    #   "http://www.twitch.tv/dreamhacktv/b/396294648"
    # @return [String] URL of this video on Twitch.
    attr_reader :url

    # @example
    #   81754
    # @return [Fixnum] The number of views this video has received all-time.
    attr_reader :view_count

    # @return [String] Description of this video.
    attr_reader :description

    # @example
    #   4205 # (1 hour, 10 minutes, 5 seconds)
    # @return [Fixnum] The length of this video (seconds).
    attr_reader :length

    # @example
    #   "StarCraft II: Heart of the Swarm"
    # @return [String] The name of the game played in this video.
    attr_reader :game_name

    # @example
    #   "http://static-cdn.jtvnw.net/jtv.thumbs/archive-396294648-320x240.jpg"
    # @return [String] URL of a preview screenshot taken from the video stream.
    attr_reader :preview_url

    # @return [Channel] The channel on which this video was originally streamed.
    attr_reader :channel

    # @example
    #   "<object data='http://www.twitch.tv/widgets/archive_embed_player.swf'>...</object>"
    # @return [String] HTML code for embedding this video on a web page.
    attr_reader :embed_html
  end

  # Query class used for finding top videos.
  # @see Video
  class Videos
    include Connection

    # Get the list of most popular videos based on view count.
    # @note The number of videos returned is potentially very large, so it's recommended that you specify a `:limit`.
    # @example
    #   Videos.top
    # @example
    #   Videos.top(:period => :month, :game => 'Super Meat Boy')
    # @example
    #   Videos.top(:period => :all, :limit => 10)
    # @param options [Hash] Filter criteria.
    # @option options [Symbol] :period (:week) Return videos only in this time period. Valid values are `:week`, `:month`, `:all`.
    # @option options [String] :game (nil) Return videos only for this game.
    # @option options [Fixnum] :limit (none) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/videos.md#get-videostop GET /videos/top
    # @raise [ArgumentError] If `:period` is not one of `:week`, `:month`, or `:all`.
    # @return [Array<Video>] List of top videos.
    def self.top(options = {})
      params = {}

      if options[:game]
        params[:game] = options[:game]
      end

      period = options[:period] || :week
      if ![:week, :month, :all].include?(period)
        raise ArgumentError, 'period'
      end

      params[:period] = period.to_s

      return connection.accumulate(
        :path => 'videos/top',
        :params => params,
        :json => 'videos',
        :class => Video,
        :limit => options[:limit],
        :offset => options[:offset]
      )
    end
  end
end
