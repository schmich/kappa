module Kappa
  # @private
  class VideoBase
    include IdEquality

    def self.get(id)
      json = connection.get("videos/#{id}")
      new(json)
    end
  end
end

module Kappa::V2
  class Video < Kappa::VideoBase
    include Connection

    def initialize(hash)
      @id = hash['id']
      @title = hash['title']
      @recorded_at = DateTime.parse(hash['recorded_at'])
      @url = hash['url']
      @view_count = hash['views']
      @description = hash['description']
      @length_sec = hash['length']
      @game_name = hash['game']
      @preview_url = hash['preview']
      @channel_name = hash['channel']['name']
      # @channel_display_name = json['channel']['display_name']
    end

    def channel
      Channel.new(connection.get("channels/#{@channel_name}"))
    end

    attr_reader :id
    attr_reader :title
    attr_reader :recorded_at
    attr_reader :url
    attr_reader :view_count
    attr_reader :description
    # TODO: Is this actually in seconds? Doesn't seem to match up with video length.
    attr_reader :length_sec
    attr_reader :game_name
    attr_reader :preview_url
    # TODO: Move this under "v.channel.name" and force the query if other attributes are requested.
    attr_reader :channel_name
  end

  class Videos
    def self.top(params = {})
    end
  end
end
