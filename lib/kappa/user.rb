require 'cgi'
require 'time'

module Kappa::V2
  # These are members of the Twitch community who have a Twitch account. If broadcasting,
  # they can own a stream that they can broadcast on their channel. If mainly viewing,
  # they might follow or subscribe to channels.
  # @see .get User.get
  # @see Channel
  # @see Stream
  class User
    include Connection
    include Kappa::IdEquality

    # @private
    def initialize(hash)
      @id = hash['_id']
      @created_at = Time.parse(hash['created_at']).utc
      @display_name = hash['display_name']
      @logo_url = hash['logo']
      @name = hash['name']
      @staff = hash['staff'] || false
      @updated_at = Time.parse(hash['updated_at']).utc
    end

    # Get a user by name.
    # @param user_name [String] The name of the user to get. This is the same as the channel or stream name.
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/users.md#get-usersuser GET /users/:user
    # @return [User] A valid `User` object if the user exists, `nil` otherwise.
    def self.get(user_name)
      encoded_name = CGI.escape(user_name)
      json = connection.get("users/#{encoded_name}")
      if !json || json['status'] == 404
        nil
      else
        new(json)
      end
    end

    # Get the `Channel` associated with this user.
    # @note This incurs an additional web request.
    # @return [Channel] The `Channel` associated with this user, or `nil` if this is a Justin.tv account.
    # @see Channel.get
    def channel
      Channel.get(@name)
    end

    # Get the live stream associated with this user.
    # @note This incurs an additional web request.
    # @return [Stream] Live stream object for this user, or `nil` if the user is not currently streaming.
    # @see #streaming?
    def stream
      Stream.get(@name)
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
      return connection.accumulate(
        :path => "users/#{@name}/follows/channels",
        :json => 'follows',
        :sub_json => 'channel',
        :class => Channel,
        :limit => options[:limit],
        :offset => options[:offset]
      )
    end

    # @param channel [String, Channel] The name of the channel (or `Channel` object) to check.
    # @return [Boolean] `true` if the user is following the channel, `false` otherwise.
    # @see #following
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/follows.md#get-usersuserfollowschannelstarget GET /users/:user/follows/:channels/:target
    def following?(channel)
      channel_name = case channel
        when String
          channel
        when Channel
          channel.name
      end

      channel_name = CGI.escape(channel_name)

      json = connection.get("users/#{@name}/follows/channels/#{channel_name}")
      status = json['status']
      return !status || (status != 404)
    end

    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @return [Time] When the user account was created (UTC).
    attr_reader :created_at

    # @return [Time] When the user account was last updated (UTC).
    attr_reader :updated_at

    # @return [String] User-friendly display name.
    attr_reader :display_name

    # @return [String] URL for the logo image.
    attr_reader :logo_url

    # @return [String] Unique Twitch name.
    attr_reader :name
  end
end
