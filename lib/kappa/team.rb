module Kappa
  class TeamBase
    include IdEquality

    def initialize(arg, connection)
      @connection = connection

      case arg
        when Hash
          parse(arg)
        when String
          json = @connection.get("teams/#{arg}")
        else
          raise ArgumentError
      end
    end
  end
end

module Kappa::V2
  class Team < Kappa::TeamBase
    #
    # GET /teams/:team
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/teams.md#get-teamsteam
    #
    def intialize(arg, connection = Connection.instance)
      super(arg, connection)
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
    
  private
    def parse(hash)
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
  end

  class Teams
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
end
