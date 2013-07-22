module Twitch::V2
  # Games are categories (e.g. League of Legends, Diablo 3) used by streams and channels.
  # Games can be searched for by query.
  # @see Games
  class Game
    include Twitch::IdEquality

    # @private
    def initialize(hash)
      @channel_count = hash['channels']
      @viewer_count = hash['viewers']

      game = hash['game']
      @id = game['_id']
      @name = game['name']
      @giantbomb_id = game['giantbomb_id']
      @box_images = Images.new(game['box'])
      @logo_images = Images.new(game['logo'])
    end

    # @example
    #   21799
    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @example
    #   "League of Legends"
    # @return [String] User-friendly game name.
    attr_reader :name

    # @example
    #   24024
    # @return [Fixnum] Unique game ID for GiantBomb.com. 
    attr_reader :giantbomb_id

    # @return [Images] Set of images for the game's box art.
    attr_reader :box_images

    # @return [Images] Set of images for the game's logo.
    attr_reader :logo_images

    # @example
    #   802
    # @return [Fixnum] Total number of channels currently streaming this game on Twitch.
    attr_reader :channel_count

    # @example
    #   68592
    # @return [Fixnum] Total number of viewers across all channels currently watching this game on Twitch.
    attr_reader :viewer_count
  end

  # A game suggestion returned by Twitch when searching for games via `Games.find`.
  # @see Games.find
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

  # Query class used for finding top games or finding games by name.
  # @see Game
  # @see GameSuggestion
  class Games
    def initialize(query)
      @query = query
    end

    # Get a list of games with the highest number of current viewers on Twitch.
    # @example
    #   Games.top
    # @example
    #   Games.top(:limit => 10)
    # @param options [Hash] Filter criteria.
    # @option options [Boolean] :hls (nil) If `true`, limit the games to those that have any streams using HLS (HTTP Live Streaming). If `false` or `nil`, do not limit.
    # @option options [Fixnum] :limit (none) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @see Game
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/games.md#get-gamestop GET /games/top
    # @return [Array<Game>] List of games sorted by number of current viewers on Twitch, most popular first.
    def top(options = {})
      params = {}

      if options[:hls]
        params[:hls] = true
      end

      return @query.connection.accumulate(
        :path => 'games/top',
        :params => params,
        :json => 'top',
        :create => Game,
        :limit => options[:limit],
        :offset => options[:offset]
      )
    end
    
    # Get a list of games with names similar to the specified name.
    # @example
    #   Games.find(:name => 'diablo')
    # @example
    #   Games.find(:name => 'starcraft', :live => true)
    # @param options [Hash] Search criteria.
    # @option options [String] :name Game name search term. This can be a partial name, e.g. `"league"`.
    # @option options [Boolean] :live (false) If `true`, only returns games that are currently live on at least one channel.
    # @option options [Fixnum] :limit (none) Limit on the number of results returned.
    # @see GameSuggestion
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/search.md#get-searchgames GET /search/games
    # @raise [ArgumentError] If `:name` is not specified.
    # @return [Array<GameSuggestion>] List of games matching the criteria.
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
