module Twitch::V2
  class Query
    def initialize(connection)
      @connection = connection
      @channels = Channels.new(self)
      @streams = Streams.new(self)
      @users = Users.new(self)
      @games = Games.new(self)
      @teams = Teams.new(self)
      @videos = Videos.new(self)
    end

    attr_reader :connection
    attr_reader :channels
    attr_reader :streams
    attr_reader :users
    attr_reader :games
    attr_reader :teams
    attr_reader :videos
  end
end
