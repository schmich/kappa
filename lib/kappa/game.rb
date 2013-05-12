module Kappa
  class GameBase
    include IdEquality
  end

  class GameSuggestionBase
    include IdEquality
  end
end

module Kappa::V2
  class Game < Kappa::GameBase
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

    attr_reader :id
    attr_reader :name
    attr_reader :giantbomb_id
    attr_reader :box_images
    attr_reader :logo_images
    attr_reader :channel_count
    attr_reader :viewer_count
  end

  class GameSuggestion < Kappa::GameSuggestionBase
    def initialize(hash)
      @id = hash['_id']
      @name = hash['name']
      @giantbomb_id = hash['giantbomb_id']
      @popularity = hash['popularity']
      @box_images = Images.new(hash['box'])
      @logo_images = Images.new(hash['logo'])
    end

    attr_reader :id
    attr_reader :name
    attr_reader :giantbomb_id
    attr_reader :popularity
    attr_reader :box_images
    attr_reader :logo_images
  end

  class Games
    include Connection

    #
    # GET /games/top
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/games.md#get-gamestop
    #
    def self.top(args = {})
      params = {}

      limit = args[:limit]
      if limit && (limit < 25)
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
    
    #
    # GET /search/games
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/search.md#get-searchgames
    #
    def self.search(params = {})
      live = params[:live] || false
      name = params[:name]

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
