module Kappa::V2
  # Games are categories (e.g. League of Legends, Diablo 3) used by streams and channels.
  # Games can be searched for by query.
  # @see Games
  class Game
    include Kappa::IdEquality

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

    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @return [String] User-friendly game name.
    attr_reader :name

    # @return [Fixnum] Unique game ID for GiantBomb.com. 
    attr_reader :giantbomb_id

    # @return [Images] Set of images for the game's box art.
    attr_reader :box_images

    # @return [Images] Set of images for the game's logo.
    attr_reader :logo_images

    # @return [Fixnum] Total number of channels currently streaming this game on Twitch.
    attr_reader :channel_count

    # @return [Fixnum] Total number of viewers across all channels currently watching this game on Twitch.
    attr_reader :viewer_count
  end

  # A game suggestion returned by Twitch when searching for games via `Games.find`.
  # @see Games.find
  class GameSuggestion
    include Kappa::IdEquality

    # @private
    def initialize(hash)
      @id = hash['_id']
      @name = hash['name']
      @giantbomb_id = hash['giantbomb_id']
      @popularity = hash['popularity']
      @box_images = Images.new(hash['box'])
      @logo_images = Images.new(hash['logo'])
    end

    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @return [String] Game name.
    attr_reader :name

    # @return [Fixnum] Unique game ID for GiantBomb.com. 
    attr_reader :giantbomb_id

    # @return [Fixnum] Relative popularity metric. Higher number means more popular.
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
    include Connection

    # Get a list of games with the highest number of current viewers on Twitch.
    # @example
    #   Games.top
    # @example
    #   Games.top(:limit => 10)
    # @param options [Hash] Filter criteria.
    # @option options [Boolean] :hls (false) TODO
    # @option options [Fixnum] :limit (none) Limit on the number of results returned.
    # @option options [Fixnum] :offset (0) Offset into the result set to begin enumeration.
    # @see Game
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/games.md#get-gamestop GET /games/top
    # @return [Array<Game>] List of games sorted by number of current viewers on Twitch, most popular first.
    def self.top(options = {})
      params = {}

      # TODO: Support :offset.
      # TODO: Support :hls.

      limit = options[:limit]
      if limit && (limit < 100)
        params[:limit] = limit
      else
        params[:limit] = 100
        limit = 0
      end

      return connection.accumulate(
        :path => 'games/top',
        :params => params,
        :json => 'top',
        :class => Game,
        :limit => limit
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
    # @see GameSuggestion
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/search.md#get-searchgames GET /search/games
    # @raise [ArgumentError] If `:name` is not specified.
    # @return [Array<GameSuggestion>] List of games matching the criteria.
    def self.find(options)
      raise ArgumentError if options.nil? || options[:name].nil?

      name = options[:name]

      params = {
        :query => name,
        :type => 'suggest'
      }

      if options[:live]
        params.merge!(:live => true)
      end

      # TODO: Use connection#accumulate here.

      games = []
      ids = Set.new

      json = connection.get('search/games', params)
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
end
