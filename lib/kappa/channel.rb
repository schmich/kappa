require 'cgi'

module Kappa::V2
  # Channels serve as the home location for a user's content. Channels have a stream, can run
  # commercials, store videos, display information and status, and have a customized page including
  # banners and backgrounds.
  # @see .get Channel.get
  # @see Stream
  # @see User
  class Channel
    # TODO:
    # c.subscriptions
    # c.start_commercial
    # c.reset_stream_key
    # c.foo = 'bar' ; c.save!
    # Current user's channel
    include Connection
    include Kappa::IdEquality

    # @private
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

    # Get a channel by name.
    # @param channel_name [String] The name of the channel to get. This is the same as the stream or user name.
    # @return [Channel] A valid `Channel` object if the channel exists, `nil` otherwise.
    def self.get(channel_name)
      encoded_name = CGI.escape(channel_name)
      json = connection.get("channels/#{encoded_name}")
      if !json || json['status'] == 404
        nil
      else
        new(json)
      end
    end

    # Does this channel have mature content? This flag is specified by the owner of the channel.
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

    # Does this channel currently have a live stream?
    # @note This makes a separate request to get the channel's stream. If you want to actually use the stream object, you should call `#stream` instead.
    # @return [Boolean] `true` if the channel currently has a live stream, `false` otherwise.
    # @see #stream
    def streaming?
      !stream.nil?
    end

    #
    # GET /channels/:channel/editors
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/channels.md#get-channelschanneleditors
    #
    # @private
    # Private until implemented.
    def editors
      # TODO
    end

    #
    # GET /channels/:channels/videos
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/videos.md#get-channelschannelvideos
    #
    # @private
    # Private until implemented.
    def videos(params = {})
      # TODO
    end

    # TODO: Requires authentication.
    # @private
    # Private until implemented.
    def subscribers
    end

    #
    # GET /channels/:channel/subscriptions/:user
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/subscriptions.md#get-channelschannelsubscriptionsuser
    #
    # TODO: Requires authentication.
    # @private
    # Private until implemented.
    def has_subscriber?(user)
      # Support User object or username (string)
    end

    #
    # GET /channels/:channel/follows
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/channels.md#get-channelschannelfollows
    #

    # Get the users following this channel.
    # @note The number of followers is potentially very large, so it's recommended that you specify a `:limit`.
    # @param :limit [Fixnum] (optional) Limit on the number of results returned. Default: no limit.
    # @param :offset [Fixnum] (optional) Offset into the result set to begin enumeration. Default: `0`.
    # @return [Array<User>] List of users following this channel.
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

    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @return [String] URL for background image.
    attr_reader :background_url

    # @return [String] URL for banner image.
    attr_reader :banner_url

    # @return [DateTime] When the channel was created.
    attr_reader :created_at

    # @return [String] User-friendly display name. This name is used for the channel's page title.
    attr_reader :display_name

    # @return [String] Name of the primary game for this channel.
    attr_reader :game_name

    # @return [String] URL for the logo image.
    attr_reader :logo_url

    # @return [String] Unique Twitch name.
    attr_reader :name

    # @return [String] Current status set by the channel's owner.
    attr_reader :status

    # @return [DateTime] When the channel was last updated. When a stream is started, its channel is updated.
    attr_reader :updated_at

    # @return [String] The URL for the channel's main page.
    attr_reader :url

    # @return [String] URL for the image shown when the stream is offline.
    attr_reader :video_banner_url

    # @return [Array<Team>] The list of teams that this channel is associated with. Not all channels have associated teams.
    attr_reader :teams
  end
end
