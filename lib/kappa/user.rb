module Kappa
  class UserBase
    include IdEquality

    def initialize(arg, connection)
      @connection = connection

      case arg
        when Hash
          parse(arg)
        when String
          json = @connection.get("users/#{arg}")
          parse(json)
        else
          raise ArgumentError
      end
    end
  end
end

module Kappa::V2
  #
  # GET /users/:user
  # https://github.com/justintv/Twitch-API/blob/master/v2_resources/users.md#get-usersuser
  #
  class User < Kappa::UserBase
    def initialize(arg, connection = Connection.instance)
      super(arg, connection)
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
    def following(params = {})
      limit = params[:limit] || 0

      channels = []
      ids = Set.new

      @connection.paginated("users/#{@name}/follows/channels", params) do |json|
        current_channels = json['follows']
        current_channels.each do |follow_json|
          channel_json = follow_json['channel']
          channel = Channel.new(channel_json, @connection)
          if ids.add?(channel.id)
            channels << channel
            if channels.count == limit
              return channels
            end
          end
        end

        !current_channels.empty?
      end

      channels
    end

    #
    # GET /users/:user/follows/:channels/:target
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/follows.md#get-usersuserfollowschannelstarget
    #
    def following?(channel_name)
      encoded_name = Addressable::URI.encode(channel_name)
      json = @connection.get("users/#{@name}/follows/channels/#{encoded_name}")
      status = json['status']
      return !status || (status != 404)
    end

    attr_reader :id
    attr_reader :created_at
    attr_reader :display_name
    attr_reader :logo_url
    attr_reader :name
    attr_reader :type
    attr_reader :updated_at
    
  private
    def parse(hash)
      @id = hash['_id']
      @created_at = DateTime.parse(hash['created_at'])
      @display_name = hash['display_name']
      @logo_url = hash['logo']
      @name = hash['name']
      @type = hash['type']
      @updated_at = DateTime.parse(hash['updated_at'])
    end
  end
end
