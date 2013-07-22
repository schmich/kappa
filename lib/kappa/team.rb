require 'time'

module Twitch::V2
  # Teams are an organization of channels.
  # @see Teams#get Teams#get
  # @see Teams#all Teams#all
  # @see Teams
  # @see Channel
  class Team
    include Twitch::IdEquality
    
    # @private
    def initialize(hash)
      @id = hash['_id']
      @info = hash['info']
      @background_url = hash['background']
      @banner_url = hash['banner']
      @logo_url = hash['logo']
      @name = hash['name']
      @display_name = hash['display_name']
      @updated_at = Time.parse(hash['updated_at']).utc
      @created_at = Time.parse(hash['created_at']).utc
      @url = "http://www.twitch.tv/team/#{@name}"
    end

    # @example
    #   12
    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @example
    #   "TeamLiquid is awesome. and esports. video games. \n\n"
    # @return [String] Info about the team. This is displayed on the team's page and can contain HTML.
    attr_reader :info

    # @example
    #   "http://static-cdn.jtvnw.net/jtv_user_pictures/team-eg-background_image-da36973b6d829ac6.png"
    # @return [String] URL for background image.
    attr_reader :background_url

    # @example
    #   "http://static-cdn.jtvnw.net/jtv_user_pictures/team-eg-banner_image-1ad9c4738f4698b1-640x125.png"
    # @return [String] URL for banner image.
    attr_reader :banner_url

    # @example
    #   "http://static-cdn.jtvnw.net/jtv_user_pictures/team-eg-team_logo_image-9107b874d4c3fc3b-300x300.jpeg"
    # @return [String] URL for the logo image.
    attr_reader :logo_url

    # @example
    #   "teamliquid"
    # @see #display_name
    # @return [String] Unique Twitch name.
    attr_reader :name

    # @example
    #   "TeamLiquid"
    # @see #name
    # @return [String] User-friendly display name. This name is used for the team's page title.
    attr_reader :display_name

    # @example
    #   2013-05-24 00:17:10 UTC
    # @return [Time] When the team was last updated (UTC).
    attr_reader :updated_at

    # @example
    #   2011-10-27 01:00:44 UTC
    # @return [Time] When the team was created (UTC).
    attr_reader :created_at

    # @example
    #   "http://www.twitch.tv/team/teamliquid"
    # @return [String] URL for the team's Twitch landing page.
    attr_reader :url
  end

  # Query class for finding all active teams.
  # @see Team
  class Teams
    # @private
    def initialize(query)
      @query = query
    end

    # Get a team by name.
    # @example
    #   Twitch.teams.get('teamliquid')
    # @param team_name [String] The name of the team to get.
    # @return [Team] A valid `Team` object if the team exists, `nil` otherwise.
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/teams.md#get-teamsteam GET /teams/:team
    def get(team_name)
      json = @query.connection.get("teams/#{team_name}")
      if json['status'] == 404
        nil
      else
        Team.new(json)
      end
    end

    # Get the list of all active teams.
    # @example
    #   Twitch.teams.all
    # @example
    #   Twitch.teams.all(:limit => 10)
    # @param options [Hash] Filter criteria.
    # @option options [Fixnum] :limit (none) Limit on the number of results returned.
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/teams.md#get-teams GET /teams
    # @return [Array<Team>] List of all active teams.
    def all(options = {})
      return @query.connection.accumulate(
        :path => 'teams',
        :json => 'teams',
        :create => Team,
        :limit => options[:limit],
        :offset => options[:offset]
      )
    end
  end
end
