module Kappa
  class ChannelBase
    include IdEquality

    def initialize(arg, connection)
      @connection = connection

      case arg
        when Hash
          parse(arg)
        when String
          json = @connection.get("channels/#{arg}")
          parse(json)
        else
          raise ArgumentError
      end
    end
  end
end

module Kappa::V2
  # TODO:
  # c.subscriptions
  # c.start_commercial
  # c.reset_stream_key
  # c.foo = 'bar' ; c.save!
  # Current user's channel
  class Channel < Kappa::ChannelBase
    def initialize(arg, connection = Connection.instance)
      super(arg, connection)
    end

    def mature?
      @mature
    end

    # TODO: Move these into derived classes?
    def stream
      # TODO: Use _links instead of hard-coding.
      json = @connection.get("streams/#{@name}")
      stream_json = json['stream']
      Stream.new(stream_json, @connection)
    end

    def streaming?
      stream.live?
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
    def followers(params = {})
      limit = params[:limit] || 0

      followers = []
      ids = Set.new

      @connection.paginated("channels/#{@name}/follows", params) do |json|
        current_followers = json['follows']
        current_followers.each do |follow_json|
          user_json = follow_json['user']
          user = User.new(user_json, @connection)
          if ids.add?(user.id)
            followers << user
            if followers.count == limit
              return followers
            end
          end
        end

        !current_followers.empty?
      end

      followers
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

    attr_accessor :id
    attr_accessor :background_url
    attr_accessor :banner_url
    attr_accessor :created_at
    attr_accessor :stream_delay_sec
    attr_accessor :display_name
    attr_accessor :game_name
    attr_accessor :logo_url
    attr_accessor :name
    attr_accessor :status
    attr_accessor :updated_at
    attr_accessor :url
    attr_accessor :video_banner_url

  private
    def parse(hash)
      @id = hash['_id']
      @background_url = hash['background']
      @banner_url = hash['banner']
      @created_at = DateTime.parse(hash['created_at'])
      @stream_delay_sec = hash['delay']
      @display_name = hash['display_name']
      @game_name = hash['game']
      @logo_url = hash['logo']
      @mature = hash['mature'] || false
      @name = hash['name']
      @status = hash['status']
      @updated_at = DateTime.parse(hash['updated_at'])
      @url = hash['url']
      @video_banner_url = hash['video_banner']
    end
  end
end
