require 'securerandom'

module Twitch
  @query = nil

  # Configure global settings for interacting with Twitch. Future requests will use these settings.
  # @example
  #   Twitch.configure do |config|
  #     config.client_id = 'sc2daily-v1.0.0'
  #     config.api = Twitch::V2
  #   end
  def self.configure(&block)
    @query = instance(&block)
  end

  def self.instance(&block)
    config = Configuration.new
    config.instance_eval(&block)
    connection = config.create(:Connection, config.client_id)
    return config.create(:Query, connection)
  end

  def self.method_missing(*args)
    @query ||= create_default_query
    @query.send(*args)
  end

  # @private
  class Configuration
    def initialize
      @api = Twitch::V2
    end

    def client_id
      # Generate a random client_id if it's not already set.
      @client_id ||= "Kappa-%s" % SecureRandom.uuid
      @client_id
    end

    def create(symbol, *args)
      @api.const_get(symbol).new(*args)
    end

    attr_writer :client_id
    attr_accessor :api
  end

private
  def self.create_default_query
    config = Configuration.new
    connection = config.create(:Connection, config.client_id)
    return config.create(:Query, connection)
  end
end
