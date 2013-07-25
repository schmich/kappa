module Twitch
  # The base class for all `Twitch` errors.
  class Error < StandardError
    # An error that occurred as the result of a request through the Twitch.tv API.
    class ResponseError < Error
      # @private
      def initialize(arg, request_url)
        super(arg)
        @request_url = request_url
      end

      # @example
      #   "https://api.twitch.tv/kraken/streams?limit=100&offset=0"
      # @return [String] The request URL that resulted in this response error.
      attr_reader :request_url
    end

    # An error indicating a malformed response from the Twitch.tv API.
    class ResponseFormatError < ResponseError
    end
  end
end
