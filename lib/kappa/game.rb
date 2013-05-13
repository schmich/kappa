module Kappa
  # @private
  class GameBase
    include IdEquality
  end

  # @private
  class GameSuggestionBase
    include IdEquality
  end
end

module Kappa::V2
  # Games are categories (e.g. League of Legends, Diablo 3) used by streams and channels.
  # Games can be searched for by query.
  # @see Games.find
  # @see Games.top
  class Game < Kappa::GameBase
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

  # A game suggestion returned by Twitch when searching for games via `Games#find`.
  # @see Games.find
  class GameSuggestion < Kappa::GameSuggestionBase
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
    # @param :hls [Boolean] TODO
    # @param :limit [Fixnum] (optional) Limit on the number of results returned. Default: no limit.
    # @param :offset [Fixnum] (optional) Offset into the result set to begin enumeration. Default: `0`.
    # @see Game
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/games.md#get-gamestop GET /games/top
    # @return [[Game]] List of games sorted by number of current viewers on Twitch, most popular first.
    def self.top(args = {})
      params = {}

      # TODO: Support :offset.
      # TODO: Support :hls.

      limit = args[:limit]
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
    # @param :name [String] Game name search term. This can be a partial name, e.g. 'league'.
    # @param :live [Boolean] (Optional) If `true`, only returns games that are currently live on at least one channel. Default: `false`.
    # @see GameSuggestion
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/search.md#get-searchgames GET /search/games
    # @return [[GameSuggestion]] List of games matching the criteria.
    def self.find(args = {})
      # TODO: Enforce :name/:live parameters

      live = args[:live] || false
      name = args[:name]

      games = []
      ids = Set.new

      json = connection.get('search/games', :query => name, :type => 'suggest', :live => live)
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
