module Kappa::V2
  # Teams are an organization of channels.
  # @see .get Team.get
  # @see Teams
  # @see Channel
  class Team
    include Connection
    include Kappa::IdEquality
    
    # @private
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

    # Get a team by name.
    # @param team_name [String] The name of the team to get.
    # @return [Team] A valid `Team` object if the team exists, `nil` otherwise.
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/teams.md#get-teamsteam GET /teams/:team
    def self.get(team_name)
      json = connection.get("teams/#{team_name}")
      if json['status'] == 404
        nil
      else
        new(json)
      end
    end

    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @return [String] Info about the team. This is displayed on the team's page and can contain HTML.
    attr_reader :info

    # @return [String] URL for background image.
    attr_reader :background_url

    # @return [String] URL for banner image.
    attr_reader :banner_url

    # @return [String] URL for the logo image.
    attr_reader :logo_url

    # @return [String] Unique Twitch name.
    attr_reader :name

    # @return [String] User-friendly display name. This name is used for the team's page title.
    attr_reader :display_name

    # @return [DateTime] When the team was last updated.
    attr_reader :updated_at

    # @return [DateTime] When the team was created.
    attr_reader :created_at
  end

  # Query class used for finding all active teams.
  # @see Team
  class Teams
    include Connection

    # Get the list of all active teams.
    # @example
    #   Teams.all
    # @example
    #   Teams.all(:limit => 10)
    # @param :limit [Fixnum] (optional) Limit on the number of results returned. Default: no limit.
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/teams.md#get-teams GET /teams
    # @return [Array<Team>] List of all active teams.
    def self.all(args = {})
      params = {}

      limit = args[:limit]
      if limit && (limit < 100)
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
