require 'cgi'
require 'time'

module Twitch::V2
  # Channels serve as the home location for a user's content. Channels have a stream, can run
  # commercials, store videos, display information and status, and have a customized page including
  # banners and backgrounds.
  # @see Channels#get Channels#get
  # @see Channels
  # @see Stream
  # @see User
  class Channel
    include Twitch::IdEquality

    # @private
    def initialize(hash, query)
      @query = query
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
      @query.streams.get(@name)
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
      @query.users.get(@name)
    end

    # Get the users following this channel.
    # @note The number of followers is potentially very large, so it's recommended that you specify a `:limit`.
    # @example
    #   f = c.followers(:limit => 20)
    # @param options [Hash] Filter criteria.
    # @option options [Fixnum] :limit (none) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @see User
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/channels.md#get-channelschannelfollows GET /channels/:channel/follows
    # @return [Array<User>] List of users following this channel.
    def followers(options = {})
      name = CGI.escape(@name)
      return @query.connection.accumulate(
        :path => "channels/#{name}/follows",
        :json => 'follows',
        :sub_json => 'user',
        :create => -> hash { User.new(hash, @query) },
        :limit => options[:limit],
        :offset => options[:offset]
      )
    end

    # Get the videos for a channel, most recently created first.
    # @note This incurs additional web requests.
    # @note You can get videos directly from a channel name via {Videos#for_channel}.
    # @example
    #   c = Twitch.channels.get('idrajit')
    #   v = c.videos(:type => :broadcasts)
    # @param options [Hash] Filter criteria.
    # @option options [Symbol] :type (:highlights) The type of videos to return. Valid values are `:broadcasts`, `:highlights`.
    # @option options [Fixnum] :limit (none) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @see Video
    # @see Videos#for_channel Videos#for_channel
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/videos.md#get-channelschannelvideos GET /channels/:channel/videos
    # @raise [ArgumentError] If `:type` is not one of `:broadcasts` or `:highlights`.
    # @return [Array<Video>] List of videos for the channel.
    def videos(options = {})
      @query.videos.for_channel(@name, options)
    end

    # @example
    #   23460970
    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @example
    #   "http://static-cdn.jtvnw.net/jtv_user_pictures/lethalfrag-channel_background_image-833a4324bc698c9b.jpeg"
    # @return [String] URL for background image.
    attr_reader :background_url

    # @example
    #   "http://static-cdn.jtvnw.net/jtv_user_pictures/lethalfrag-channel_header_image-463a4670c91c2b61-640x125.jpeg"
    # @return [String] URL for banner image.
    attr_reader :banner_url

    # @example
    #   2011-07-15 07:53:58 UTC
    # @return [Time] When the channel was created (UTC).
    attr_reader :created_at

    # @example
    #   "Lethalfrag"
    # @see #name
    # @return [String] User-friendly display name. This name is used for the channel's page title.
    attr_reader :display_name

    # @example
    #   "Super Meat Boy"
    # @return [String] Name of the primary game for this channel.
    attr_reader :game_name

    # @example
    #   "http://static-cdn.jtvnw.net/jtv_user_pictures/lethalfrag-profile_image-050adf252718823b-300x300.png"
    # @return [String] URL for the logo image.
    attr_reader :logo_url

    # @example
    #   "lethalfrag"
    # @see #display_name
    # @return [String] Unique Twitch name.
    attr_reader :name

    # @example
    #   "(Day 563/731) | Dinner and a Game (Cooking at http://twitch.tv/lookatmychicken)"
    # @return [String] Current status set by the channel's owner.
    attr_reader :status

    # @example
    #   2013-07-21 05:27:58 UTC
    # @return [Time] When the channel was last updated (UTC). For example, when a stream is started, its channel is updated.
    attr_reader :updated_at

    # @example
    #   "http://www.twitch.tv/lethalfrag"
    # @return [String] The URL for the channel's main page.
    attr_reader :url

    # @example
    #   "http://static-cdn.jtvnw.net/jtv_user_pictures/lethalfrag-channel_offline_image-3b801b2ccc11830b-640x360.jpeg"
    # @return [String] URL for the image shown when the stream is offline.
    attr_reader :video_banner_url

    # @see Team
    # @return [Array<Team>] The list of teams that this channel is associated with. Not all channels have associated teams.
    attr_reader :teams
  end

  # Query class for finding channels.
  # @see Channel
  class Channels
    # @private
    def initialize(query)
      @query = query
    end

    # Get a channel by name.
    # @example
    #   c = Twitch.channels.get('day9tv')
    # @param channel_name [String] The name of the channel to get. This is the same as the stream or user name.
    # @return [Channel] A valid `Channel` object if the channel exists, `nil` otherwise.
    def get(channel_name)
      name = CGI.escape(channel_name)
      json = @query.connection.get("channels/#{name}")

      # HTTP 422 can happen if the channel is associated with a Justin.tv account.
      if !json || json['status'] == 404 || json['status'] == 422
        nil
      else
        Channel.new(json, @query)
      end
    end
  end
end
