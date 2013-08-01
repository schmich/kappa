module Twitch
  # @private
  class Status
    def self.map(status_map, &block)
      begin
        block.call
      rescue Error::ClientError, Error::ServerError => e
        if status_map.include? e.status
          status_map[e.status]
        else
          raise
        end
      end
    end
  end
end
