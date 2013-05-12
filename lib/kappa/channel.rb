require 'cgi'

module Kappa
  class ChannelBase
    include IdEquality

    def self.get(channel_name)
      encoded_name = CGI.escape(channel_name)
      json = connection.get("channels/#{encoded_name}")
      # TODO: Handle errors.
      new(json)
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
    include Connection

    def initialize(hash)
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

      @teams = []
      teams = hash['teams']
      teams.each do |team_json|
        @teams << Team.new(team_json)
      end
    end

    def mature?
      @mature
    end

    # TODO: Move these into derived classes?
    def stream
      Stream.get(@name)
    end

    def streaming?
      !stream.nil?
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
    def followers(args = {})
      params = {}

      limit = args[:limit]
      if limit && (limit < 25)
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

    attr_reader :id
    attr_reader :background_url
    attr_reader :banner_url
    attr_reader :created_at
    attr_reader :stream_delay_sec
    attr_reader :display_name
    attr_reader :game_name
    attr_reader :logo_url
    attr_reader :name
    attr_reader :status
    attr_reader :updated_at
    attr_reader :url
    attr_reader :video_banner_url
    attr_reader :teams
  end
end
