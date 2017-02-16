require 'cgi'
require 'time'

module Twitch::V5
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
      @background_url = hash['background']
      @banner_url = hash['banner']
      @created_at = Time.parse(hash['created_at']).utc
      @display_name = hash['display_name']
      @info = hash['info']
      @logo_url = hash['logo']
      @name = hash['name']
      @updated_at = Time.parse(hash['updated_at']).utc
      name = CGI.escape(@name)
      @url = "http://www.twitch.tv/team/#{name}"
    end

    # @example
    #   12
    # @return [Fixnum] Unique Twitch ID.
    attr_reader :id

    # @example
    #   "http://static-cdn.jtvnw.net/jtv_user_pictures/team-eg-background_image-da36973b6d829ac6.png"
    # @return [String] URL for background image.
    attr_reader :background_url

    # @example
    #   "http://static-cdn.jtvnw.net/jtv_user_pictures/team-eg-banner_image-1ad9c4738f4698b1-640x125.png"
    # @return [String] URL for banner image.
    attr_reader :banner_url

    # @example
    #   2011-10-27 01:00:44 UTC
    # @return [Time] When the team was created (UTC).
    attr_reader :created_at

    # @example
    #   "TeamLiquid"
    # @see #name
    # @return [String] User-friendly display name. This name is used for the team's page title.
    attr_reader :display_name

    # @example
    #   "TeamLiquid is awesome. and esports. video games. \n\n"
    # @return [String] Info about the team. This is displayed on the team's page and can contain HTML.
    attr_reader :info

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
    #   2013-05-24 00:17:10 UTC
    # @return [Time] When the team was last updated (UTC).
    attr_reader :updated_at

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
      name = CGI.escape(team_name)
      Twitch::Status.map(404 => nil) do
        json = @query.connection.get("teams/#{name}")
        Team.new(json)
      end
    end

    # Get the list of all active teams.
    # @example
    #   Twitch.teams.all
    # @example
    #   Twitch.teams.all(:limit => 10)
    # @example
    #   Twitch.teams do |team|
    #     next if (Time.now - team.updated_at) > (60 * 60 * 24)
    #     puts team.url
    #   end
    # @param options [Hash] Filter criteria.
    # @option options [Fixnum] :limit (nil) Limit on the number of results returned.
    # @yield Optional. If a block is given, each team is yielded.
    # @yieldparam [Team] team Current team.
    # @see https://github.com/justintv/Twitch-API/blob/master/v2_resources/teams.md#get-teams GET /teams
    # @return [Array<Team>] All active teams, if no block is given.
    # @return [nil] If a block is given.
    def all(options = {}, &block)
      return @query.connection.accumulate(
        :path => 'teams',
        :json => 'teams',
        :create => Team,
        :limit => options[:limit],
        :offset => options[:offset],
        &block
      )
    end
  end
end
