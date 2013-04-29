require 'httparty'
require 'json'
require 'addressable/uri'
require 'securerandom'
require 'set'

# TODO
# https://github.com/justintv/Twitch-API
# Blocks
#   GET /users/:login/blocks
#   PUT /users/:user/blocks/:target
#   DELETE /users/:user/blocks/:target
# Channels
#   - GET /channels/:channel
#   GET /channel
#   GET /channels/:channel/editors
#   PUT /channels/:channel
#   GET /channels/:channel/videos
#   GET /channels/:channel/follows
#   DELETE /channels/:channel/stream_key
#   POST /channels/:channel/commercial
# Chat
#   GET /chat/:channel
#   GET /chat/emoticons
# Follows
#   GET /channels/:channel/follows
#   GET /users/:user/follows/channels
#   GET /users/:user/follows/channels/:target
#   PUT /users/:user/follows/channels/:target
#   DELETE /users/:user/follows/channels/:target
# Games
#   - GET /games/top
# Ingests
#   GET /ingests
# Root
#   GET /
# Search
#   GET /search/streams
#   - GET /search/games
# Streams
#   - GET /streams/:channel
#   - GET /streams
#   GET /streams/featured
#   GET /streams/summary
#   GET /streams/followed
# Subscriptions
#   GET /channels/:channel/subscriptions
#   GET /channels/:channel/subscriptions/:user
# Teams
#   GET /teams
#   GET /teams/:team
# Users
#   GET /users/:user
#   GET /user
#   GET /streams/followed
# Videos
#   GET /videos/:id
#   GET /videos/top
#   GET /channels/:channel/videos

# Overarching
# - Common query syntax
# - Access to raw properties (e.g. stream['game'] or stream.raw('game'))
# - Paginated results take a block to allow for intermediate processing/termination

# t = Kappa::Client.new
# c = t.channel('lagtvmaximusblack')
# c.editors -> [...]
# c.videos -> [...]
# c.followers -> [...]
# c.subscriptions
# c.start_commercial
# c.reset_stream_key
# c... ; c.save! 
# TODO: current user channel

# t = Kappa::Client.new
# t.streams.all
# t.streams.all(:limit => 10)
# t.streams.featured
# t.streams.where(:channel => 'lagtvmaximusblack')
# t.streams.where(:channel => [...], :game => '...', :embeddable => t/f, :hls => t/f)
# t.stream_summary

module Kappa
  class Connection
    include HTTParty
    debug_output $stdout

    def initialize(base_url)
      @base_url = Addressable::URI.parse(base_url)

      uuid = SecureRandom.uuid
      # TODO: Embed current library version.
      @client_id = "Kappa-v1-#{uuid}"

      @last_request_time = Time.now - RATE_LIMIT_SEC
    end

    def get(path, query = nil)
      # TODO: Rate-limiting.

      request_url = @base_url + path

      # Handle non-JSON response
      # Handle invalid JSON
      # Handle non-200 codes

      headers = {
        'Client-ID' => @client_id,
        'Accept' => 'application/vnd.twitchtv.v2+json'
      }

      response = rate_limit do
        self.class.get(request_url, :headers => headers, :query => query)
      end

      json = response.body
      return JSON.parse(json)
    end

    def paginated(path, params = {})
      limit = [params[:limit] || 100, 100].min
      offset = params[:offset] || 0

      path_uri = Addressable::URI.parse(path)
      query = { 'limit' => limit, 'offset' => offset }
      path_uri.query_values ||= {}
      path_uri.query_values = path_uri.query_values.merge(query)

      request_url = path_uri.to_s

      params = params.dup
      params.delete(:limit)
      params.delete(:offset)

      # TODO: Hande request retry.
      loop do
        json = get(request_url, params)

        if json['error'] && (json['status'] == 503)
          break
        end

        break if !yield(json)

        links = json['_links']
        next_url = links['next']

        next_uri = Addressable::URI.parse(next_url)
        offset = next_uri.query_values['offset'].to_i

        total = json['_total']
        break if total && (offset > total)

        request_url = next_url
      end
    end

  private
    def rate_limit
      delta = Time.now - @last_request_time
      delay = [RATE_LIMIT_SEC - delta, 0].max

      sleep delay if delay > 0

      begin
        return yield
      ensure
        @last_request_time = Time.now
      end
    end

    RATE_LIMIT_SEC = 1
  end

  module IdEquality
    def hash
      @id.hash
    end

    def eql?(other)
      other && (self.id == other.id)
    end

    def ==(other)
      eql?(other)
    end
  end

  class Client
    def initialize(opts = {})
      base_url = opts[:base_url] || DEFAULT_BASE_URL
      @conn = Connection.new(base_url)
    end

    #
    # GET /users/:user
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/users.md#get-usersuser
    #
    def user(user_name)
      encoded_name = Addressable::URI.encode(user_name)
      User.new(@conn.get("users/#{encoded_name}"), @conn)
    end

    #
    # GET /channels/:channel
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/channels.md#get-channelschannel
    #
    def channel(channel_name)
      encoded_name = Addressable::URI.encode(channel_name)
      Channel.new(@conn.get("channels/#{encoded_name}"), @conn)
    end

    #
    # GET /streams/:channel
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/streams.md#get-streamschannel 
    #
    def stream(channel_name)
      encoded_name = Addressable::URI.encode(channel_name)
      json = @conn.get("streams/#{encoded_name}")
      stream_json = json['stream']
      if stream_json
        Stream.new(json['stream'], @conn)
      else
        nil
      end
    end

    def streams
      @streams ||= StreamQuery.new(@conn)
    end

    def games
      @games ||= GameQuery.new(@conn)
    end

    #
    # GET /teams/:team
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/teams.md#get-teamsteam
    #
    def team(team_name)
      encoded_name = Addressable::URI.encode(team_name)
      json = @conn.get("teams/#{encoded_name}")
      Team.new(json, @conn)
    end

    def teams
      @teams ||= TeamQuery.new(@conn)
    end

    #
    # GET /videos/:id
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/videos.md#get-videosid
    #
    def video(video_id)
      Video.new(@conn.get("videos/#{video_id}"), @conn)
    end

    def videos
      @videos ||= VideoQuery.new(@conn)
    end

    # TODO: Move?
    def stats
      Stats.new(@conn.get('streams/summary'), @conn)
    end

    DEFAULT_BASE_URL = 'https://api.twitch.tv/kraken/'
  end

  class Channel
    def initialize(json, conn)
      @conn = conn

      @id = json['_id']
      @background_url = json['background']
      @banner_url = json['banner']
      @created_at = DateTime.parse(json['created_at'])
      @stream_delay_sec = json['delay']
      @display_name = json['display_name']
      @game = json['game']
      @logo_url = json['logo']
      @mature = json['mature'] || false
      @name = json['name']
      @status = json['status']
      @updated_at = DateTime.parse(json['updated_at'])
      @url = json['url']
      @video_banner = json['video_banner']
    end

    include IdEquality

    def mature?
      @mature
    end

    def stream
      encoded_name = Addressable::URI.encode(@name)
      json = @conn.get("streams/#{encoded_name}")
      stream_json = json['stream']
      if stream_json
        Stream.new(json['stream'], @conn)
      else
        nil
      end
    end

    def streaming?
      !self.stream.nil?
    end

    #
    # GET /channels/:channel/editors
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/channels.md#get-channelschanneleditors
    #
    def editors
      # TODO: ...
    end

    #
    # GET /channels/:channels/videos
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/videos.md#get-channelschannelvideos
    #
    def videos(params = {})
      # TODO: ...
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

      @conn.paginated("channels/#{@name}/follows", params) do |json|
        current_followers = json['follows']
        current_followers.each do |follow_json|
          user_json = follow_json['user']
          user = User.new(user_json, @conn)
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

# t = Kappa::Client.new
# c = t.channel('lagtvmaximusblack')
# c.followers -> [...]
# c.subscriptions
# c.start_commercial
# c.reset_stream_key
# c... ; c.save! 
# TODO: current user channel

    attr_reader :id
    attr_reader :background_url
    attr_reader :banner_url
    attr_reader :created_at
    attr_reader :stream_delay_sec
    attr_reader :display_name
    attr_reader :game
    attr_reader :logo_url
    attr_reader :name
    attr_reader :status
    attr_reader :updated_at
    attr_reader :url
    attr_reader :video_banner
  end

  class TeamQuery
    def initialize(conn)
      @conn = conn
    end

    #
    # GET /teams
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/teams.md#get-teams
    #
    def all(params = {})
      limit = params[:limit] || 0

      teams = []
      ids = Set.new

      @conn.paginated('teams', params) do |json|
        teams_json = json['teams']
        teams_json.each do |team_json|
          team = Team.new(team_json, @conn)
          if ids.add?(team.id)
            teams << team
            if teams.count == limit
              return teams
            end
          end
        end

        !teams_json.empty?
      end

      teams
    end
  end

  class StreamQuery
    def initialize(conn)
      @conn = conn
    end

    def all
    end

    #
    # GET /streams
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/streams.md
    # :game (single, string), :channel (string array), :limit (int), :offset (int), :embeddable (bool), :hls (bool)
    #
    def where(params = {})
      limit = params[:limit] || 0

      params = params.dup
      if params[:channel]
        params[:channel] = params[:channel].join(',')
      end

      streams = []
      ids = Set.new

      @conn.paginated('streams', params) do |json|
        current_streams = json['streams']
        current_streams.each do |stream_json|
          stream = Stream.new(stream_json, @conn)
          if ids.add?(stream.id)
            streams << stream
            if streams.count == limit
              return streams
            end
          end
        end

        !current_streams.empty?
      end

      streams
    end

    #
    # GET /streams/featured
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/streams.md#get-streamsfeatured
    #
    def featured(params = {})
      limit = params[:limit] || 0

      streams = []
      ids = Set.new

      @conn.paginated('streams/featured', params) do |json|
        current_streams = json['featured']
        current_streams.each do |featured_json|
          # TODO: Capture more information from the featured_json structure (need a FeaturedStream class?)
          stream_json = featured_json['stream']
          stream = Stream.new(stream_json, @conn)
          if ids.add?(stream.id)
            streams << stream
            if streams.count == limit
              return streams
            end
          end
        end

        !current_streams.empty?
      end

      streams
    end
  end

  class Stream
    def initialize(json, conn)
      @conn = conn

      @id = json['_id']
      @broadcaster = json['broadcaster']
      @game_name = json['game']
      @name = json['name']
      @viewer_count = json['viewers']
      @preview_url = json['preview']
      @channel = Channel.new(json['channel'], @conn)
    end

    include IdEquality

    def channel
    end

    attr_reader :id
    attr_reader :broadcaster
    attr_reader :game_name
    attr_reader :name
    attr_reader :viewer_count
    attr_reader :preview_url
    attr_reader :channel
  end

  class GameQuery
    def initialize(conn)
      @conn = conn
    end

    #
    # GET /games/top
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/games.md#get-gamestop
    #
    def top(params = {})
      limit = params[:limit] || 0

      games = []
      ids = Set.new

      @conn.paginated('games/top', params) do |json|
        current_games = json['top']
        current_games.each do |game_json|
          game = Game.new(game_json)
          if ids.add?(game.id)
            games << game
            if games.count == limit
              return games
            end
          end
        end
      end

      games
    end

    #
    # GET /search/games
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/search.md#get-searchgames
    #
    def search(params = {})
      live = params[:live] || false
      name = params[:name]

      games = []
      ids = Set.new

      json = @conn.get('search/games', :query => name, :type => 'suggest', :live => live)
      all_games = json['games']
      all_games.each do |game_json|
        game = GameSuggestion.new(game_json)
        if ids.add?(game.id)
          games << game
        end
      end

      games
    end
  end

  class VideoQuery
    # ...
    def top
    end
  end

  class Game
    def initialize(json)
      @channel_count = json['channels']
      @viewer_count = json['viewers']

      game = json['game']
      @id = game['_id']
      @name = game['name']
      @giantbomb_id = game['giantbomb_id']
      @box_images = Images.new(game['box'])
      @logo_images = Images.new(game['logo'])
    end

    include IdEquality

    attr_reader :id
    attr_reader :name
    attr_reader :giantbomb_id
    attr_reader :box_images
    attr_reader :logo_images
    attr_reader :channel_count
    attr_reader :viewer_count
  end

  class GameSuggestion
    def initialize(json)
      @id = json['_id']
      @name = json['name']
      @giantbomb_id = json['giantbomb_id']
      @popularity = json['popularity']
      @box_images = Images.new(json['box'])
      @logo_images = Images.new(json['logo'])
    end

    include IdEquality

    attr_reader :id
    attr_reader :name
    attr_reader :giantbomb_id
    attr_reader :popularity
    attr_reader :box_images
    attr_reader :logo_images
  end

  class Images
    def initialize(json)
      @large_url = json['large']
      @medium_url = json['medium']
      @small_url = json['small']
      @template_url = json['template']
    end

    def url(width, height)
      @template_url.gsub('{width}', width.to_s, '{height}', height.to_s)
    end

    attr_reader :large_url
    attr_reader :medium_url
    attr_reader :small_url
    attr_reader :template_url
  end

  class User
    def initialize(json, conn)
      @conn = conn

      # TODO: nil checks
      @id = json['_id']
      @created_at = DateTime.parse(json['created_at'])
      @display_name = json['display_name']
      @logo_url = json['logo']
      @name = json['name']
      @type = json['type']
      @updated_at = DateTime.parse(json['updated_at'])
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

      @conn.paginated("users/#{@name}/follows/channels", params) do |json|
        current_channels = json['follows']
        current_channels.each do |follow_json|
          channel_json = follow_json['channel']
          channel = Channel.new(channel_json, @conn)
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
      json = @conn.get("users/#{@name}/follows/channels/#{encoded_name}")
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
  end

  class Stats
    def initialize(json, conn)
      @viewer_count = json['viewers']
      @stream_count = json['channels']
    end

    attr_reader :viewer_count
    attr_reader :stream_count
  end

  class Team
    def initialize(json, conn)
      @id = json['_id']
      @info = json['info']
      @background_url = json['background']
      @banner_url = json['banner']
      @logo_url = json['logo']
      @name = json['name']
      @display_name = json['display_name']
      @updated_at = DateTime.parse(json['updated_at'])
      @created_at = DateTime.parse(json['created_at'])
    end

    include IdEquality

    attr_reader :id
    attr_reader :info
    attr_reader :background_url
    attr_reader :banner_url
    attr_reader :logo_url
    attr_reader :name
    attr_reader :display_name
    attr_reader :updated_at
    attr_reader :created_at
  end

  class Video
    def initialize(json, conn)
      @conn = conn

      @id = json['id']
      @title = json['title']
      @recorded_at = DateTime.parse(json['recorded_at'])
      @url = json['url']
      @view_count = json['views']
      @description = json['description']
      @length_sec = json['length']
      @game_name = json['game']
      @preview_url = json['preview']
      @channel_name = json['channel']['name']
      # @channel_display_name = json['channel']['display_name']
    end

    include IdEquality

    def channel
      Channel.new(@conn.get("channels/#{@channel_name}"), @conn)
    end

    attr_reader :id
    attr_reader :title
    attr_reader :recorded_at
    attr_reader :url
    attr_reader :view_count
    attr_reader :description
    # TODO: Is this actually in seconds? Doesn't seem to match up with video length.
    attr_reader :length_sec
    attr_reader :game_name
    attr_reader :preview_url
    # TODO: Move this under "v.channel.name" and force the query if other attributes are requested.
    attr_reader :channel_name
  end
end

=begin
k = Kappa::Client.new
v = k.video('a396294648')
=end

=begin
u.following.each do |channel|
  puts channel.display_name
end
=end

=begin
streams = t.streams.where(:channel => ['psystarcraft', 'destiny', 'combatex', 'eghuk', 'eg_idra', 'day9tv', 'fxoqxc', 'colqxc', 'liquidnony', 'demuslim', 'whitera', 'khaldor', 'acermma'])
streams.each do |stream|
  puts "#{stream.channel.display_name}: #{stream.viewer_count}"
  puts "#{stream.channel.status}"
end
=end

=begin
streams = t.streams.where(:game => 'StarCraft II: Heart of the Swarm')
streams.each do |stream|
  puts stream.channel.display_name
end
=end

=begin
puts t.stats.viewer_count
puts t.stats.stream_count
=end

=begin
s = t.streams.where(:channel => ['lagtvmaximusblack', 'sc2tv_ru'])
s.each do |stream|
  puts stream.channel.name
end
=end

=begin
s = t.streams.featured
s.each do |stream|
  puts stream.channel.name
end
=end

=begin
games = t.games.top(:limit => 150).sort_by(&:viewer_count).reverse
puts games.count

games.each do |game|
  puts "#{game.name}: #{game.viewer_count}"
end
=end

#c = t.channel('lagtvmaximusblack')
#s = c.stream
#puts s.id
