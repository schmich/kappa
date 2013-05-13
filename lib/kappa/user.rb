require 'cgi'

module Kappa
  # @private
  class UserBase
    include IdEquality

    #
    # GET /users/:user
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/users.md#get-usersuser
    #
    # TODO: Include in documentation.
    def self.get(user_name)
      json = connection.get("users/#{user_name}")
      if json['status'] == 404
        nil
      else
        new(json)
      end
    end
  end
end

module Kappa::V2
  class User < Kappa::UserBase
    include Connection

    # @private
    def initialize(hash)
      @id = hash['_id']
      @created_at = DateTime.parse(hash['created_at'])
      @display_name = hash['display_name']
      @logo_url = hash['logo']
      @name = hash['name']
      @staff = hash['staff'] || false
      @updated_at = DateTime.parse(hash['updated_at'])
    end

    # @return [Channel] The `Channel` associated with this user account.
    def channel
      # TODO
    end

    # @return [Boolean] `true` if the user is a member of the Twitch.tv staff, `false` otherwise.
    def staff?
      @staff
    end

    #
    # GET /channels/:channel/subscriptions/:user
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/subscriptions.md#get-channelschannelsubscriptionsuser
    #

    # TODO: Requires authentication. Private until implemented.
    # @private
    def subscribed_to?(channel_name)
    end

    #
    # GET /users/:user/follows/channels
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/follows.md#get-usersuserfollowschannels
    #

    # @param :limit [Fixnum] (optional) Limit on the number of results returned. Default: no limit.
    # @see #following?
    # @return [Array<Channel>] List of channels the user is currently following.
    def following(args = {})
      params = {}

      limit = args[:limit]
      if limit && (limit < 100)
        params[:limit] = limit
      else
        params[:limit] = 100
        limit = 0
      end

      return connection.accumulate(
        :path => "users/#{@name}/follows/channels",
        :params => params,
        :json => 'follows',
        :sub_json => 'channel',
        :class => Channel,
        :limit => limit
      )
    end

    #
    # GET /users/:user/follows/:channels/:target
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/follows.md#get-usersuserfollowschannelstarget
    #

    # @param channel [String, Channel] The name of the channel (or `Channel` object) to check.
    # @return [Boolean] `true` if the user is following the channel, `false` otherwise.
    # @see #following
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

    # @return [DateTime] When the user account was created.
    attr_reader :created_at

    # @return [DateTime] When the user account was last updated.
    attr_reader :updated_at

    # @return [String] User-friendly display name.
    attr_reader :display_name

    # @return [String] URL for the logo image.
    attr_reader :logo_url

    # @return [String] Unique Twitch name.
    attr_reader :name

    # TODO: Authenticated user attributes.
    # attr_reader :email
    # def partnered?
  end
end
