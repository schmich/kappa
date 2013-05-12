module Kappa
  # @private
  class UserBase
    include IdEquality

    #
    # GET /users/:user
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/users.md#get-usersuser
    #
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

    def initialize(hash)
      @id = hash['_id']
      @created_at = DateTime.parse(hash['created_at'])
      @display_name = hash['display_name']
      @logo_url = hash['logo']
      @name = hash['name']
      @staff = hash['staff'] || false
      @updated_at = DateTime.parse(hash['updated_at'])
    end

    def channel
      # TODO
    end

    def staff?
      @staff
    end

    #
    # GET /channels/:channel/subscriptions/:user
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/subscriptions.md#get-channelschannelsubscriptionsuser
    #
    # TODO: Requires authentication.
    def subscribed_to?(channel_name)
    end

    #
    # GET /streams/followed
    # TODO: Authenticate.
    # TODO: Only valid for authenticated user, might not belong here.
    #
    # GET /users/:user/follows/channels
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/follows.md#get-usersuserfollowschannels
    #
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
    def following?(channel_name)
      json = connection.get("users/#{@name}/follows/channels/#{channel_name}")
      status = json['status']
      return !status || (status != 404)
    end

    attr_reader :id
    attr_reader :created_at
    attr_reader :display_name
    attr_reader :logo_url
    attr_reader :name
    attr_reader :updated_at

    # TODO: Authenticated user attributes.
    # attr_reader :email
    # def partnered?
  end
end
