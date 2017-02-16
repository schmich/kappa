module Twitch::V5
  # Games are categories (e.g. League of Legends, Diablo 3) used by streams and channels.
  # Games can be searched for by query.
  # @see Games#top Games#top
  # @see Games#find Games#find
  # @see Games
  class Game
    include Twitch::IdEquality

    # @private
    def initialize(hash, query)
      @query = query
      @channel_count = hash['channels']
      @viewer_count = hash['viewers']

      game = hash['game']
      @id = game['_id']
      @box_images = Images.new(game['box'])
      @giantbomb_id = game['giantbomb_id']
      @logo_images = Images.new(game['logo'])
      @name = game['name']
      @popularity = game['popularity']
    end

    # Get streams for this game.
    # @example
    #   game.streams
    # @example
    #   game.streams(:embeddable => true, :limit => 20)
    # @example
    #   game.streams do |stream|
    #     next if stream.viewer_count < 1000
    #     puts stream.url
    #   end
    # @param options [Hash] Search criteria.
    # @option options [Array<String, Channel, #name>] :channel Only return streams for these channels.
    #   If a channel is not currently streaming, it is omitted. You must specify an array of channels
    #   or channel names.
    # @option options [Boolean] :embeddable (nil) If `true`, limit the streams to those that can be embedded. If `false` or `nil`, do not limit.
    # @option options [Boolean] :hls (nil) If `true`, limit the streams to those using HLS (HTTP Live Streaming). If `false` or `nil`, do not limit.
    # @option options [Fixnum] :limit (nil) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @yield Optional. If a block is given, each stream found is yielded.
    # @yieldparam [Stream] stream Current stream.
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/streams.md#get-streams GET /streams
    # @raise [ArgumentError] If `:channel` is not an array.
    # @return [Array<Stream>] Streams matching the specified criteria, if no block is given.
    # @return [nil] If a block is given.
    def streams(options = {}, &block)
      @query.streams.find(options.merge(:game => @name), &block)
    end

    # @example
    #   21799
    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @example
    #   802
    # @return [Fixnum] Total number of channels currently streaming this game on Twitch.
    attr_reader :channel_count

    # @example
    #   68592
    # @return [Fixnum] Total number of viewers across all channels currently watching this game on Twitch.
    attr_reader :viewer_count

    # @return [Images] Set of images for the game's box art.
    attr_reader :box_images

    # @example
    #   24024
    # @return [Fixnum] Unique game ID for GiantBomb.com.
    attr_reader :giantbomb_id

    # @return [Images] Set of images for the game's logo.
    attr_reader :logo_images

    # @example
    #   "League of Legends"
    # @return [String] User-friendly game name.
    attr_reader :name

    # @example
    #   "League of Legends"
    # @return [String] Popularity of the game.
    attr_reader :popularity
  end

  # A game suggestion returned by Twitch when searching for games via `Twitch.games.find`.
  # @see Games#find Games#find
  class GameSuggestion
    include Twitch::IdEquality

    # @private
    def initialize(hash)
      @id = hash['_id']
      @name = hash['name']
      @giantbomb_id = hash['giantbomb_id']
      @popularity = hash['popularity']
      @box_images = Images.new(hash['box'])
      @logo_images = Images.new(hash['logo'])
    end

    # @example
    #   155075940
    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @example
    #   "Dark Souls"
    # @return [String] Game name.
    attr_reader :name

    # @example
    #   32697
    # @return [Fixnum] Unique game ID for GiantBomb.com.
    attr_reader :giantbomb_id

    # @example
    #   67
    # @return [Fixnum] Relative popularity metric. Higher number means more popular. This value only has meaning relative to other popularity values.
    attr_reader :popularity

    # @return [Images] Set of images for the game's box art.
    attr_reader :box_images

    # @return [Images] Set of images for the game's logo.
    attr_reader :logo_images
  end

  # Query class for finding top games or finding games by name.
  # @see Game
  # @see GameSuggestion
  class Games
    # @private
    def initialize(query)
      @query = query
    end

    # Get a list of games with the highest number of current viewers on Twitch.
    # @example
    #   Twitch.games.top
    # @example
    #   Twitch.games.top(:limit => 10)
    # @example
    #   Twitch.games.top do |game|
    #     next if game.viewer_count < 10000
    #     puts game.name
    #   end
    # @param options [Hash] Filter criteria.
    # @option options [Boolean] :hls (nil) If `true`, limit the games to those that have any streams using HLS (HTTP Live Streaming). If `false` or `nil`, do not limit.
    # @option options [Fixnum] :limit (nil) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @yield Optional. If a block is given, each top game is yielded.
    # @yieldparam [Game] game Current game.
    # @see Game Game
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/games.md#get-gamestop GET /games/top
    # @return [Array<Game>] Games sorted by number of current viewers on Twitch, highest first, if no block is given.
    # @return [nil] If a block is given.
    def top(options = {}, &block)
      params = {}

      if options[:hls]
        params[:hls] = true
      end

      return @query.connection.accumulate(
        :path => 'games/top',
        :params => params,
        :json => 'top',
        :create => -> hash { Game.new(hash, @query) },
        :limit => options[:limit],
        :offset => options[:offset],
        &block
      )
    end

    # Get a list of games with names similar to the specified name.
    # @example
    #   Twitch.games.find(:name => 'diablo')
    # @example
    #   Twitch.games.find(:name => 'starcraft', :live => true)
    # @example
    #   Twitch.games.find(:name => 'starcraft') do |suggestion|
    #     next if suggestion.name =~ /heart of the swarm/i
    #     puts suggestion.name
    #   end
    # @param options [Hash] Search criteria.
    # @option options [String] :name Game name search term. This can be a partial name, e.g. `"league"`.
    # @option options [Boolean] :live (false) If `true`, only returns games that are currently live on at least one channel.
    # @option options [Fixnum] :limit (nil) Limit on the number of results returned.
    # @yield Optional. If a block is given, each game suggestion is yielded.
    # @yieldparam [GameSuggestion] suggestion Current game suggestion.
    # @see GameSuggestion GameSuggestion
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/search.md#get-searchgames GET /search/games
    # @raise [ArgumentError] If `:name` is not specified.
    # @return [Array<GameSuggestion>] Games matching the criteria, if no block is given.
    # @return [nil] If a block is given.
    def find(options)
      raise ArgumentError, 'options' if options.nil?
      raise ArgumentError, 'name' if options[:name].nil?

      params = {
        :query => options[:name],
        :type => 'suggest'
      }

      if options[:live]
        params.merge!(:live => true)
      end

      return @query.connection.accumulate(
        :path => 'search/games',
        :params => params,
        :json => 'games',
        :create => GameSuggestion,
        :limit => options[:limit]
      )
    end
  end
end
