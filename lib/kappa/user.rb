require 'cgi'
require 'time'

module Twitch::V2
  # These are members of the Twitch community who have a Twitch account. If broadcasting,
  # they can own a stream that they can broadcast on their channel. If mainly viewing,
  # they might follow or subscribe to channels.
  # @see .get User.get
  # @see Channel
  # @see Stream
  class User
    include Twitch::IdEquality

    # @private
    def initialize(hash, query)
      @query = query
      @id = hash['_id']
      @created_at = Time.parse(hash['created_at']).utc
      @display_name = hash['display_name']
      @logo_url = hash['logo']
      @name = hash['name']
      @staff = hash['staff'] || false
      @updated_at = Time.parse(hash['updated_at']).utc
    end

    # Get the `Channel` associated with this user.
    # @note This incurs an additional web request.
    # @return [Channel] The `Channel` associated with this user, or `nil` if this is a Justin.tv account.
    # @see Channel.get
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
      @staff
    end

    # Get the channels the user is currently following.
    # @param options [Hash] Filter criteria.
    # @option options [Fixnum] :limit (none) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @see #following?
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/follows.md#get-usersuserfollowschannels GET /users/:user/follows/channels
    # @return [Array<Channel>] List of channels the user is currently following.
    def following(options = {})
      return @query.connection.accumulate(
        :path => "users/#{@name}/follows/channels",
        :json => 'follows',
        :sub_json => 'channel',
        :create => -> hash { Channel.new(hash, @query) },
        :limit => options[:limit],
        :offset => options[:offset]
      )
    end

    # @param channel [String/Channel/User/Stream/#name] The name of the channel to check.
    # @return [Boolean] `true` if the user is following the channel, `false` otherwise.
    # @see #following
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/follows.md#get-usersuserfollowschannelstarget GET /users/:user/follows/:channels/:target
    def following?(target)
      name = if target.respond_to?(:name)
        target.name
      else
        target.to_s
      end

      name = CGI.escape(name)

      json = @query.connection.get("users/#{@name}/follows/channels/#{name}")
      status = json['status']
      return !status || (status != 404)
    end

    # @example
    #   23945610 
    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @example
    #   2011-08-08 21:03:44 UTC
    # @return [Time] When the user account was created (UTC).
    attr_reader :created_at

    # @example
    #   2013-07-19 23:51:43 UTC
    # @return [Time] When the user account was last updated (UTC).
    attr_reader :updated_at

    # @example
    #   "LAGTVMaximusBlack"
    # @return [String] User-friendly display name.
    attr_reader :display_name

    # @example
    #   "http://static-cdn.jtvnw.net/jtv_user_pictures/lagtvmaximusblack-profile_image-4b77a2305f5d85c8-300x300.png"
    # @return [String] URL for the logo image.
    attr_reader :logo_url

    # @example
    #   "lagtvmaximusblack"
    # @return [String] Unique Twitch name.
    attr_reader :name
  end

  class Users
    def initialize(query)
      @query = query
    end

    # Get a user by name.
    # @param user_name [String] The name of the user to get. This is the same as the channel or stream name.
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/users.md#get-usersuser GET /users/:user
    # @return [User] A valid `User` object if the user exists, `nil` otherwise.
    def get(user_name)
      encoded_name = CGI.escape(user_name)
      json = @query.connection.get("users/#{encoded_name}")
      if !json || json['status'] == 404
        nil
      else
        User.new(json, @query)
      end
    end
  end
end
