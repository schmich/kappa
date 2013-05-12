module Kappa
  class TeamBase
    include IdEquality

    #
    # GET /teams/:team
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/teams.md#get-teamsteam
    #
    def self.get(team_name)
      json = connection.get("teams/#{team_name}")
      if json['status'] == 404
        nil
      else
        new(json)
      end
    end
  end
end

module Kappa::V2
  class Team < Kappa::TeamBase
    include Connection
    
    def initialize(hash)
      @id = hash['_id']
      @info = hash['info']
      @background_url = hash['background']
      @banner_url = hash['banner']
      @logo_url = hash['logo']
      @name = hash['name']
      @display_name = hash['display_name']
      @updated_at = DateTime.parse(hash['updated_at'])
      @created_at = DateTime.parse(hash['created_at'])
    end

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

  class Teams
    include Connection

    #
    # GET /teams
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/teams.md#get-teams
    #
    def self.all(args = {})
      params = {}

      limit = args[:limit]
      if limit && (limit < 25)
        params[:limit] = limit
      else
        params[:limit] = 100
        limit = 0
      end

      return connection.accumulate(
        :path => 'teams',
        :params => params,
        :json => 'teams',
        :class => Team,
        :limit => limit
      )
    end
  end
end
