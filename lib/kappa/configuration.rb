require 'singleton'
require 'securerandom'

module Kappa
  def self.configure(&block)
    Configuration.instance.instance_eval(&block)
  end

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
