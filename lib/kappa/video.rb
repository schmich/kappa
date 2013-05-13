require 'cgi'

module Kappa::V2
  # Videos are broadcasts or highlights owned by a channel. Broadcasts are unedited
  # videos that are saved after a streaming session. Highlights are videos edited from
  # broadcasts by the channel's owner.
  # @see .get Video.get
  # @see Videos
  # @see Channel
  class Video
    include Connection
    include Kappa::IdEquality

    # @private
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

    # Get a video by ID.
    # @example
    #   v = Video.get('a396294648')
    #   v.title # => "DreamHack Open Stockholm 26-27 April"
    # @param id [String] The ID of the video to get.
    # @raise [ArgumentError] If `id` is `nil` or blank.
    # @return [Video] A valid `Video` object if the video exists, `nil` otherwise.
    def self.get(id)
      raise ArgumentError if !id || id.strip.empty?

      encoded_id = CGI.escape(id)
      json = connection.get("videos/#{encoded_id}")
      if !json || json['status'] == 404
        nil
      else
        new(json)
      end
    end

    # @note This does incur an additional web request.
    # @return [Channel] The channel on which this video was originally streamed.
    def channel
      Channel.new(connection.get("channels/#{@channel_name}"))
    end

    # @return [Fixnum] Unique Twitch ID for this video.
    attr_reader :id

    # @return [String] Title of this video. This is seen on the video's page.
    attr_reader :title

    # @return [DateTime] When this video was recorded.
    attr_reader :recorded_at

    # @return [String] URL to view this video on Twitch.
    attr_reader :url

    # @return [Fixnum] The number of views this video has received all-time.
    attr_reader :view_count

    # @return [String] Description of this video.
    attr_reader :description

    # @return [Fixnum] The length of this video in seconds.
    attr_reader :length_sec # TODO: Is this actually in seconds? Doesn't seem to match up with video length.

    # @return [String] The name of the game played in this video.
    attr_reader :game_name

    # @return [String] URL of a preview screenshot taken from the video stream.
    attr_reader :preview_url

    # @return [String] The name of the channel on which this video was originally streamed.
    attr_reader :channel_name # TODO: Move this under "v.channel.name" and force the query if other attributes are requested.
  end

  # Query class used for finding top videos.
  # @see Video
  class Videos
    # @private
    # Private until implemented.
    def self.top(params = {})
      # TODO
    end
  end
end
