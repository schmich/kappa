require 'singleton'
require 'securerandom'

module Kappa
  # Configure global settings for interacting with Twitch. Future requests will use these settings.
  # @example
  #   Kappa.configure do |config|
  #     config.client_id = 'sc2daily-v1.0.0'
  #   end
  def self.configure(&block)
    Configuration.instance.instance_eval(&block)
  end

  # @private
  class Configuration
    include Singleton

    def client_id
      # Generate a random client_id if it's not already set.
      @client_id ||= "Kappa-%s" % SecureRandom.uuid
      @client_id
    end

    attr_writer :client_id
  end
end
