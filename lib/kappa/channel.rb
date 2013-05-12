require 'cgi'

module Kappa
  # @private
  class ChannelBase
    include IdEquality

    def self.get(channel_name)
      encoded_name = CGI.escape(channel_name)
      json = connection.get("channels/#{encoded_name}")
      if !json || json['status'] == 404
        nil
      else
        new(json)
      end
    end
  end
end

module Kappa::V2
  class Channel < Kappa::ChannelBase
    # TODO:
    # c.subscriptions
    # c.start_commercial
    # c.reset_stream_key
    # c.foo = 'bar' ; c.save!
    # Current user's channel
    include Connection

    def initialize(hash)
      @id = hash['_id']
      @background_url = hash['background']
      @banner_url = hash['banner']
      @created_at = DateTime.parse(hash['created_at'])
      @display_name = hash['display_name']
      @game_name = hash['game']
      @logo_url = hash['logo']
      @mature = hash['mature'] || false
      @name = hash['name']
      @status = hash['status']
      @updated_at = DateTime.parse(hash['updated_at'])
      @url = hash['url']
      @video_banner_url = hash['video_banner']

      @teams = []
      teams = hash['teams']
      teams.each do |team_json|
        @teams << Team.new(team_json)
      end
    end

    # This flag is specified by the owner of the channel.
    # @return [Boolean] `true` if the channel has mature content, `false` otherwise.
    def mature?
      @mature
    end

    # Get the live stream associated with this channel.
    # @return [Stream] Live stream object for this channel, or `nil` if the channel is not currently streaming.
    # @see #streaming?
    def stream
      Stream.get(@name)
    end

    # This makes a separate request to get the channel's stream. If you want to actually use
    # the stream object, you should call `#stream` instead.
    # @return [Boolean] `true` if the channel currently has a live stream, `false` otherwise.
    # @see #stream
    def streaming?
      !stream.nil?
    end

    #
    # GET /channels/:channel/editors
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/channels.md#get-channelschanneleditors
    #
    def editors
      # TODO
    end

    #
    # GET /channels/:channels/videos
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/videos.md#get-channelschannelvideos
    #
    def videos(params = {})
      # TODO
    end

    #
    # GET /channels/:channel/follows
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/channels.md#get-channelschannelfollows
    # TODO: Warning: this set can be very large, this can run for very long time, recommend using :limit/:offset.
    #
    def followers(args = {})
      params = {}

      limit = args[:limit]
      if limit && (limit < 100)
        params[:limit] = limit
      else
        params[:limit] = 100
        limit = 0
      end

      return connection.accumulate(
        :path => "channels/#{@name}/follows",
        :params => params,
        :json => 'follows',
        :sub_json => 'user',
        :class => User,
        :limit => limit
      )
    end

    # TODO: Requires authentication.
    def subscribers
    end

    #
    # GET /channels/:channel/subscriptions/:user
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/subscriptions.md#get-channelschannelsubscriptionsuser
    #
    # TODO: Requires authentication.
    def has_subscriber?(user)
      # Support User object or username (string)
    end

    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @return [String] URL for background image.
    attr_reader :background_url

    # @return [String] URL for banner image.
    attr_reader :banner_url

    # @return [DateTime] When the channel was created.
    attr_reader :created_at

    # @return [String] Display name, e.g. name used for page title.
    attr_reader :display_name

    # @return [String] Name of the primary game for this channel.
    attr_reader :game_name

    # @return [String] URL for the logo image.
    attr_reader :logo_url

    # @return [String] Unique Twitch name.
    attr_reader :name

    # @return [String] Current status.
    attr_reader :status

    # @return [DateTime] When the channel was last updated, e.g. last stream time.
    attr_reader :updated_at

    # @return [String] The URL for the channel's main page.
    attr_reader :url

    # @return [String] URL for the image shown when the stream is offline.
    attr_reader :video_banner_url

    attr_reader :teams
  end
end
