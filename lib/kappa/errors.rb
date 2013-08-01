module Twitch
  # The base class for all `Twitch` errors.
  class Error < StandardError
    # An error that occurred as the result of a request to the Twitch.tv API.
    class ResponseError < Error
      # @private
      def initialize(arg, url, status, body)
        super(arg)
        @url = url
        @status = status
        @body = body
      end

      # @example
      #   "https://api.twitch.tv/kraken/streams?limit=100&offset=0"
      # @return [String] The request URL that resulted in this response error.
      attr_reader :url

      # @example
      #   500
      # @return [Fixnum] The HTTP status code for the response.
      attr_reader :status

      # @example
      #   '{"status":422,"message":"Channel desrow is not available on Twitch","error":"Unprocessable Entity"}'
      # @return [String] The response body.
      attr_reader :body
    end

    # An error indicating an HTTP client error code (4xx) from the Twitch.tv API.
    class ClientError < ResponseError
    end

    # An error indicating an HTTP server error code (5xx) from the Twitch.tv API.
    class ServerError < ResponseError
    end

    # An error indicating a malformed response from the Twitch.tv API.
    # All Twitch.tv responses are expected to valid JSON objects.
    class FormatError < ResponseError
    end
  end
end
