require 'cgi'
require 'time'

module Twitch::V5
  # These are members of the Twitch community who have a Twitch account. If broadcasting,
  # they can own a stream that they can broadcast on their channel. If mainly viewing,
  # they might follow or subscribe to channels.
  # @see Users#get Users#get
  # @see Users
  # @see Channel
  # @see Stream
  class User
    include Twitch::IdEquality

    # @private
    def initialize(hash, query)
      @query = query
      @id = hash['_id']
      @bio = hash['bio']
      @created_at = Time.parse(hash['created_at']).utc
      @display_name = hash['display_name']
      @email = hash['email']
      @email_verified = hash['email_verified']
      @logo_url = hash['logo']
      @name = hash['name']
      @partnered = hash['partnered']
      @twitter_connected = hash['twitter_connected']
      @type = hash['type']
      @updated_at = Time.parse(hash['updated_at']).utc
    end

    # Get the `Channel` associated with this user.
    # @note This incurs an additional web request.
    # @return [Channel] The `Channel` associated with this user, or `nil` if this is a Justin.tv account.
    # @see Channel#get Channel#get
    def channel
      @query.channels.get(@name)
    end

    # Get the live stream associated with this user.
    # @note This incurs an additional web request.
    # @return [Stream] Live stream object for this user, or `nil` if the user is not currently streaming.
    # @see #streaming?
    def stream
      @query.streams.get(@name)
    end

    # Is this user currently streaming?
    # @note This makes a separate request to get the user's stream. If you want to actually use the stream object, you should call `#stream` instead.
    # @return [Boolean] `true` if the user currently has a live stream, `false` otherwise.
    # @see #stream
    def streaming?
      !stream.nil?
    end

    # @return [Boolean] `true` if the user is a member of the Twitch.tv staff, `false` otherwise.
    def staff?
      true if @type == 'staff'
      false if @type != 'staff'
    end

    # Whether the user has verified their email.
    # @return [Boolean] `true` if the user has verified their email, `false` otherwise.
    def email_verified?
      @email_verified
    end

    # Whether the user is partnered.
    # @return [Boolean] `true` if the user is partnered, `false` otherwise.
    def partnered?
      @partnered
    end

    # Whether this user is twitter connected.
    # @return [Boolean] `true` if the user has verified their email, `false` otherwise.
    def twitter_connected?
      @twitter_connected
    end

    # Get the channels the user is currently following.
    # @example
    #   user.following(:limit => 10)
    # @example
    #   user.following do |channel|
    #     next if channel.game_name !~ /starcraft/i
    #     puts channel.display_name
    #   end
    # @param options [Hash] Filter criteria.
    # @option options [Fixnum] :limit (nil) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @yield Optional. If a block is given, each followed channel is yielded.
    # @yieldparam [Channel] channel Current channel.
    # @see #following?
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/follows.md#get-usersuserfollowschannels GET /users/:user/follows/channels
    # @return [Array<Channel>] Channels the user is currently following, if no block is given.
    # @return [nil] If a block is given.
    def following(options = {}, &block)
      id = CGI.escape(@id)
      return @query.connection.accumulate(
        path: "users/#{id}/follows/channels",
        json: 'follows',
        sub_json: 'channel',
        create: -> hash { Channel.new(hash, @query) },
        limit: options[:limit],
        offset: options[:offset],
        &block
      )
    end

    # @param target [String, Channel, User, Stream, #name] The name of the channel to check.
    # @return [Boolean] `true` if the user is following the channel, `false` otherwise.
    # @see #following
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/follows.md#get-usersuserfollowschannelstarget GET /users/:user/follows/channels/:target
    def following?(target)
      id = target.id#if target.respond_to?(:id)
      #  target.id
      #else
      #  target.id
      #end

      user_id = CGI.escape(@id)
      channel_id = CGI.escape(id)

      Twitch::Status.map(404 => false) do
        @query.connection.get("users/#{user_id}/follows/channels/#{channel_id}")
        true
      end
    end

    # @example
    #   23945610
    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @example
    #   "Just a gamer playing games and chatting. :)"
    # @return [String] User's bio.
    attr_reader :bio

    # @example
    #   2011-08-08 21:03:44 UTC
    # @return [Time] When the user account was created (UTC).
    attr_reader :created_at

    # @example
    #   "LAGTVMaximusBlack"
    # @return [String] User-friendly display name.
    attr_reader :display_name

    # @example
    #   "example@example.com"
    # @return [String] The user's email.
    attr_reader :email

    # @example
    #   "http://static-cdn.jtvnw.net/jtv_user_pictures/lagtvmaximusblack-profile_image-4b77a2305f5d85c8-300x300.png"
    # @return [String] URL for the logo image.
    attr_reader :logo_url

    # @example
    #   "lagtvmaximusblack"
    # @return [String] Unique Twitch name.
    attr_reader :name

    # @example
    #   "Staff"
    # @return [String] User type.
    attr_reader :type

    # @example
    #   2013-07-19 23:51:43 UTC
    # @return [Time] When the user account was last updated (UTC).
    attr_reader :updated_at
  end

  # Query class for finding users.
  # @see User
  class Users
    # @private
    def initialize(query)
      @query = query
    end

    # Get a user by name.
    # @example
    #   Twitch.users.get('totalbiscuit')
    # @param user_name [String] The name of the user to get. This is the same as the channel or stream name.
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/users.md#get-usersuser GET /users/:user
    # @return [User] A valid `User` object if the user exists, `nil` otherwise.
    def get(user_name)
      name = CGI.escape(user_name)
      query = { login: name }
      user_json = @query.connection.get('users', query)
      userhash = user_json['users'][0]
      id = userhash['_id']
      Twitch::Status.map(404 => nil) do
        json = @query.connection.get("users/#{id}")
        User.new(json, @query)
      end
    end
  end
end
