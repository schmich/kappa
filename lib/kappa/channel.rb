require 'cgi'
require 'time'

module Kappa::V2
  # Channels serve as the home location for a user's content. Channels have a stream, can run
  # commercials, store videos, display information and status, and have a customized page including
  # banners and backgrounds.
  # @see .get Channel.get
  # @see Stream
  # @see User
  class Channel
    include Connection
    include Kappa::IdEquality

    # @private
    def initialize(hash)
      @id = hash['_id']
      @background_url = hash['background']
      @banner_url = hash['banner']
      @created_at = Time.parse(hash['created_at']).utc
      @display_name = hash['display_name']
      @game_name = hash['game']
      @logo_url = hash['logo']
      @mature = hash['mature'] || false
      @name = hash['name']
      @status = hash['status']
      @updated_at = Time.parse(hash['updated_at']).utc
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

      # HTTP 422 can happen if the channel is associated with a Justin.tv account.
      if !json || json['status'] == 404 || json['status'] == 422
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
    # @note This incurs an additional web request.
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

    # Get the owner of this channel.
    # @note This incurs an additional web request.
    # @return [User] The user that owns this channel.
    def user
      User.get(@name)
    end

    # Get the users following this channel.
    # @note The number of followers is potentially very large, so it's recommended that you specify a `:limit`.
    # @param options [Hash] Filter criteria.
    # @option options [Fixnum] :limit (none) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @see User
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/channels.md#get-channelschannelfollows GET /channels/:channel/follows
    # @return [Array<User>] List of users following this channel.
    def followers(options = {})
      params = {}

      return connection.accumulate(
        :path => "channels/#{@name}/follows",
        :params => params,
        :json => 'follows',
        :sub_json => 'user',
        :class => User,
        :limit => options[:limit],
        :offset => options[:offset]
      )
    end

    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @return [String] URL for background image.
    attr_reader :background_url

    # @return [String] URL for banner image.
    attr_reader :banner_url

    # @return [Time] When the channel was created (UTC).
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

    # @return [Time] When the channel was last updated (UTC). For example, when a stream is started, its channel is updated.
    attr_reader :updated_at

    # @return [String] The URL for the channel's main page.
    attr_reader :url

    # @return [String] URL for the image shown when the stream is offline.
    attr_reader :video_banner_url

    # @return [Array<Team>] The list of teams that this channel is associated with. Not all channels have associated teams.
    attr_reader :teams
  end
end
