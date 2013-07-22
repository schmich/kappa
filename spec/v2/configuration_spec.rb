require 'rspec'
require 'yaml'
require 'kappa'
require 'common'
require 'securerandom'
require 'webmock/rspec'

describe Twitch do
  before do
    WebMocks.load_dir(fixture('configuration'))
  end

  after do
    WebMock.reset!
  end

  describe '.configure' do
    it 'sets Client-ID header if client_id is set' do
      client_id = SecureRandom.uuid

      Twitch.configure do |config|
        config.client_id = client_id
      end

      c = Twitch.channels.get('giantwaffle')
      c.should_not be_nil

      a_request(:get, 'https://api.twitch.tv/kraken/channels/giantwaffle')
        .with(:headers => { 'Client-ID' => client_id })
        .should have_been_made.once
    end
  end

  describe '.instance' do
    it 'sets Client-ID header if client_id is set' do
      default_client_id = SecureRandom.uuid
      instance_client_id = SecureRandom.uuid

      Twitch.configure do |config|
        config.client_id = default_client_id
      end

      instance = Twitch.instance do |config|
        config.client_id = instance_client_id
      end

      c = instance.channels.get('giantwaffle')
      c.should_not be_nil

      a_request(:get, 'https://api.twitch.tv/kraken/channels/giantwaffle')
        .with(:headers => { 'Client-ID' => instance_client_id })
        .should have_been_made.once
    end
  end
end
