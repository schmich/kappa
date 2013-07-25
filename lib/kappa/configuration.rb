require 'securerandom'

module Twitch
  @query = nil

  # Configure global settings for interacting with Twitch. Future requests
  # through the `Twitch` module will use these settings.
  # @example
  #   Twitch.configure do |config|
  #     config.client_id = 'sc2daily-v1.0.0'
  #     config.api = Twitch::V2
  #   end
  #
  #   streams = Twitch.streams.featured(:limit => 10)
  # @param client_id [String] When making requests to Twitch,
  #   you must specify a client ID for your application. If you do not specify a client ID,
  #   Twitch reserves the right to rate-limit your application without warning. Defaults to
  #   a random string, but in real applications, this should be set.
  # @param api [Module] The version of the Twitch API to use. Defaults to `Twitch::V2`.
  def self.configure(&block)
    @query = instance(&block)
  end

  # Create a new interface to Twitch. This allows you to have multiple separate
  # connections to Twitch in the same process, each with its own configuration.
  # @example
  #   client_a = Twitch.instance do |config|
  #     config.client_id = 'App-A-v2.0.0'
  #   end
  #
  #   client_b = Twitch.instance do |config|
  #     config.client_id = 'App-B-v3.0.0'
  #   end
  #
  #   streams = client_a.streams.featured(:limit => 10)
  #   channel = client_b.channels.get('destiny')
  def self.instance(&block)
    config = Configuration.new
    config.instance_eval(&block)
    connection = config.create(:Connection, config.client_id)
    return config.create(:Query, connection)
  end

  # @private
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
  # @private
  def self.create_default_query
    config = Configuration.new
    connection = config.create(:Connection, config.client_id)
    return config.create(:Query, connection)
  end
end
